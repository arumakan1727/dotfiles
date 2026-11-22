#!/usr/bin/env bash
# Update pinned.toml to the latest chezmoi / mise releases that satisfy the
# release-age policy (mirrors mise minimum_release_age / UV_EXCLUDE_NEWER: do not
# adopt a release younger than N days). Always verify the chezmoi checksums
# signature with the repo-pinned cosign key. For changed sections, check every
# tarball's SHA-256 and verify each mise tarball's GitHub artifact attestation
# against the release tag and release.yml workflow.
#
# USAGE:
#   ./update-pins.sh [--days N] [--dry-run] [--allow-downgrade]
#
#   --days N           release-age window in days (default: $INSTALL_BEFORE_DAYS or 7)
#   --dry-run          verify as usual and show the diff without writing pinned.toml
#   --allow-downgrade  if the latest age-compliant release is OLDER than the
#                      current pin (i.e. the current pin violates the policy),
#                      downgrade to enforce it. Default: keep current pin.
#
# Maintenance tools: curl, gh, jq, openssl, awk, date, and sha256sum or shasum.
# Authenticate gh with GH_TOKEN, GITHUB_TOKEN, or gh auth login.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly PINNED="$SCRIPT_DIR/pinned.toml"
# From twpayne/chezmoi's assets/cosign/cosign.pub (also shipped as chezmoi_cosign.pub
# in v2.74.1). Rotation requires a manual, reviewed change to installer/keys/chezmoi_cosign.pub.
readonly CHEZMOI_COSIGN_KEY="$SCRIPT_DIR/keys/chezmoi_cosign.pub"

# shellcheck source-path=SCRIPTDIR source=lib/secure_fetch.sh
. "$SCRIPT_DIR/lib/secure_fetch.sh"

DAYS="${INSTALL_BEFORE_DAYS:-7}"
DRY_RUN=0
ALLOW_DOWNGRADE=0

die() { echo "[ERR] $*" >&2; exit 1; }
info() { echo "[*] $*"; }
warn() { echo "[WARN] $*" >&2; }

# Platforms recorded per tool (must match pinned.toml keys and the upstream
# asset naming). chezmoi: chezmoi_<ver>_<key>.tar.gz ; mise: mise-v<ver>-<key/_/->.tar.gz
readonly -a CHEZMOI_KEYS=(darwin_arm64 darwin_amd64 linux_arm64 linux_amd64)
readonly -a MISE_KEYS=(macos_arm64 macos_x64 linux_arm64 linux_x64)

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --days) shift; [ $# -gt 0 ] || die "--days requires a value"; DAYS="$1" ;;
      --days=*) DAYS="${1#*=}" ;;
      --dry-run) DRY_RUN=1 ;;
      --allow-downgrade) ALLOW_DOWNGRADE=1 ;;
      -h | --help) sed -n '1d; /^#/p; /^#/!q' "${BASH_SOURCE[0]}"; exit 0 ;;
      *) die "unknown argument: $1" ;;
    esac
    shift
  done
  case "$DAYS" in
    "" | *[!0-9]*) die "--days must be a non-negative integer: '$DAYS'" ;;
  esac
}

require_tools() {
  local t
  for t in curl gh jq openssl awk date; do
    command -v "$t" >/dev/null 2>&1 || die "required tool not found: $t"
  done
  command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 \
    || die "required tool not found: sha256sum or shasum"
}

curl_get() { curl -fsSL --proto '=https' --tlsv1.2 "$@"; }

# Newest non-draft, non-prerelease release at least $DAYS old. Prints tag_name
# (may carry a leading 'v'); empty if none.
pick_release() { # <owner/repo>
  local repo="$1" now cutoff
  now="$(date +%s)"
  cutoff=$((now - DAYS * 86400))
  gh api --hostname github.com "repos/$repo/releases?per_page=50" | jq -r --argjson cutoff "$cutoff" '
    # Surface API error objects (rate limit / bad token / 404) clearly instead
    # of letting `.[]` iterate an object and crash on a null date.
    if type != "array" then error("GitHub API did not return a release array: \(.message // .)") else . end
    | [ .[]
        | select(.draft | not)
        | select(.prerelease | not)
        | select(.published_at != null)            # skip releases lacking a publish date
        | { tag: .tag_name, t: (.published_at | fromdateiso8601) }
      ]
    | map(select(.t <= $cutoff))
    | sort_by(.t) | reverse | .[0].tag // empty'
}

# Extract one asset sha256 from a checksum file body on stdin.
# Matches "<sha>  <asset>" or "<sha>  ./<asset>".
sha_for_asset() { # <asset_name>
  awk -v a="$1" '$2==a || $2=="./"a { print $1; found=1; exit } END { exit !found }'
}

# Current pinned value for a section and key (empty if absent).
pinned_value() { # <section> <key>
  awk -v s="$1" -v key="$2" '
    /^[[:space:]]*\[/ { l=$0; gsub(/[][[:space:]]/,"",l); cur=l; next }
    cur==s {
      eq=index($0,"="); if(eq<=0) next
      k=substr($0,1,eq-1); gsub(/[[:space:]]/,"",k)
      if(k==key && match($0,/"[^"]*"/)){ print substr($0,RSTART+1,RLENGTH-2); exit }
    }' "$PINNED"
}

# Reproduce an existing section verbatim (header + its lines).
extract_section() { # <section>
  awk -v s="$1" '
    /^[[:space:]]*\[/ {
      l=$0; gsub(/[][[:space:]]/,"",l)
      if (l==s) { inblk=1; print; next }
      if (inblk) { inblk=0 }
    }
    inblk { print }
  ' "$PINNED"
}

# Is $2 strictly older than $1 (i.e. adopting $2 would be a downgrade)?
# Pure-awk numeric dotted-version compare — no `sort -V` (BSD sort lacks it on
# older macOS). Valid for chezmoi (2.70.5) and mise (2026.6.1) style versions.
is_downgrade() { # <current> <target>
  local cur="$1" tgt="$2"
  [ -n "$cur" ] || return 1
  [ "$cur" != "$tgt" ] || return 1
  awk -v a="$cur" -v b="$tgt" 'BEGIN {
    n = split(a, av, "."); m = split(b, bv, ".")
    lim = (n > m) ? n : m
    for (i = 1; i <= lim; i++) {
      ai = (i <= n) ? av[i] + 0 : 0
      bi = (i <= m) ? bv[i] + 0 : 0
      if (ai > bi) exit 0   # current > target -> target is a downgrade
      if (ai < bi) exit 1
    }
    exit 1                  # equal -> not a downgrade
  }'
}

verify_chezmoi_checksums() { # <checksums URL> <downloaded checksums file>
  local url="$1" file="$2" bundle="$2.sigstore.json" sig="$2.sig" status digest
  # Inspect the final HTTP status. A transport error must not select the legacy format.
  status="$(curl_get --no-fail -o "$bundle" -w '%{http_code}' "$url.sigstore.json")" \
    || die "chezmoi: failed to download $url.sigstore.json"
  case "$status" in
    200)
      digest="$(openssl dgst -sha256 -binary "$file" | openssl base64 -A)" \
        || die "chezmoi: failed to hash $file"
      jq -ers --arg digest "$digest" '
        if length == 1 then .[0].messageSignature else error("expected one Sigstore bundle") end
        | if .messageDigest.algorithm == "SHA2_256" and .messageDigest.digest == $digest
          then .signature | strings | select(length > 0)
          else error("checksums digest mismatch") end
      ' "$bundle" > "$sig" || die "chezmoi: invalid Sigstore bundle for ${file##*/}"
      ;;
    404)
      info "chezmoi: no Sigstore bundle (HTTP 404), using ${file##*/}.sig"
      curl_get -o "$sig" "$url.sig" || die "chezmoi: failed to download $url.sig"
      ;;
    *) die "chezmoi: HTTP $status fetching $url.sigstore.json" ;;
  esac
  openssl base64 -d -A -in "$sig" -out "$sig.der" || die "chezmoi: failed to decode signature"
  openssl dgst -sha256 -verify "$CHEZMOI_COSIGN_KEY" -signature "$sig.der" "$file" >/dev/null \
    || die "chezmoi: invalid checksums signature for ${file##*/}"
  info "${file##*/}: verified signature with the pinned cosign key"
}

# Emit the section on stdout. Diagnostics and verifier output go to stderr.
resolve_section() { # <section> <owner/repo> <platform_key>...
  local section="$1" repo="$2" cur target
  shift 2
  cur="$(pinned_value "$section" version)" || die "$section: failed to read pinned version"
  target="$(pick_release "$repo")" || die "$section: release lookup failed"
  [ -n "$target" ] || die "$section: no release found within the $DAYS-day age policy"
  target="${target#v}" # normalise leading v

  if is_downgrade "$cur" "$target"; then
    if [ "$ALLOW_DOWNGRADE" -eq 1 ]; then
      warn "$section: DOWNGRADE $cur -> $target (current pin is newer than the ${DAYS}-day policy)"
    else
      warn "$section: current pin $cur is NEWER than latest age-compliant $target; keeping $cur (use --allow-downgrade to enforce policy)"
      target="$cur"
    fi
  elif [ "$target" != "$cur" ]; then
    info "$section: update $cur -> $target" >&2
  fi

  [[ "$target" =~ ^[0-9]+(\.[0-9]+)+$ ]] || die "$section: invalid release version: $target"
  local url="https://github.com/$repo/releases/download/v$target" checksums
  case "$section" in
    chezmoi) checksums="chezmoi_${target}_checksums.txt" ;;
    mise)    checksums="SHASUMS256.txt" ;;
    *) die "unknown section: $section" ;;
  esac
  curl_get "$url/$checksums" -o "$work_dir/$checksums" || die "$section: failed to fetch $checksums"
  if [ "$section" = chezmoi ]; then
    verify_chezmoi_checksums "$url/$checksums" "$work_dir/$checksums" >&2
  fi

  local key pin_key asset sha pinned_sha width=7 changed=0
  local -a assets sums
  [ "$target" = "$cur" ] || changed=1
  for key in "$@"; do
    case "$section" in
      chezmoi) asset="chezmoi_${target}_${key}.tar.gz" ;;
      mise)    asset="mise-v${target}-${key//_/-}.tar.gz" ;;
    esac
    sha="$(sha_for_asset "$asset" < "$work_dir/$checksums")" || die "$checksums: missing $asset"
    [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || die "$checksums: invalid SHA-256 for $asset"
    assets+=("$asset")
    sums+=("$sha")
    pin_key="sha256_$key"
    pinned_sha="$(pinned_value "$section" "$pin_key")" || die "$section: failed to read $pin_key"
    [ "$sha" = "$pinned_sha" ] || changed=1
    [ "${#pin_key}" -le "$width" ] || width=${#pin_key}
  done

  if [ "$changed" -eq 0 ]; then
    info "$section $target: version and all checksums unchanged; skipping tarball verification" >&2
    extract_section "$section"
    return
  fi

  local i=0 ref="refs/tags/v$target"
  printf '[%s]\n' "$section"
  printf '%-*s = "%s"\n' "$width" version "$target"
  for key in "$@"; do
    asset="${assets[i]}"
    sha="${sums[i]}"
    TMPDIR="$work_dir" secure_fetch "$url/$asset" "$sha" "$work_dir/$asset" >&2 \
      || die "$section: download or checksum verification failed for $asset"
    info "$asset: verified SHA-256" >&2
    if [ "$section" = mise ]; then
      gh attestation verify "$work_dir/$asset" --repo "$repo" --source-ref "$ref" \
        --cert-identity "https://github.com/$repo/.github/workflows/release.yml@$ref" >&2 \
        || die "$section: attestation verification failed for $asset (v$target)"
      info "$asset: verified attestation" >&2
    fi
    printf '%-*s = "%s"\n' "$width" "sha256_$key" "$sha"
    i=$((i + 1))
  done
}

# Sanity-check generated content before it overwrites pinned.toml: both
# sections, both version lines, and all 8 platform keys must be present, and
# every sha256_* value must be 64 hex chars (matching secure_fetch's check).
validate_content() { # <content>
  local content="$1" key
  printf '%s\n' "$content" | grep -q '^\[chezmoi\]' || return 1
  printf '%s\n' "$content" | grep -q '^\[mise\]'    || return 1
  for key in version sha256_darwin_arm64 sha256_darwin_amd64 sha256_linux_arm64 sha256_linux_amd64 \
             sha256_macos_arm64 sha256_macos_x64 sha256_linux_x64; do
    printf '%s\n' "$content" | grep -q "^${key} " || return 1
  done
  # every sha256_* value is exactly 64 hex chars
  printf '%s\n' "$content" \
    | awk '/^sha256_/ { v=$3; gsub(/"/,"",v); if (v !~ /^[0-9a-f]{64}$/) { bad=1 } } END { exit bad?1:0 }'
}

main() {
  parse_args "$@"
  require_tools
  [ -f "$PINNED" ] || die "pinned.toml not found: $PINNED"
  [ -f "$CHEZMOI_COSIGN_KEY" ] || die "chezmoi: pinned cosign public key not found: $CHEZMOI_COSIGN_KEY"
  work_dir="$(mktemp -d "${TMPDIR:-/tmp}/update-pins.XXXXXX")" || die "mktemp failed"
  readonly work_dir
  trap 'rm -rf -- "$work_dir"' EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM

  info "release-age policy: >= ${DAYS} days old"

  local cz_block mise_block hb_block new_content tmp
  cz_block="$(resolve_section chezmoi twpayne/chezmoi "${CHEZMOI_KEYS[@]}")"
  mise_block="$(resolve_section mise jdx/mise "${MISE_KEYS[@]}")"
  # [homebrew] は GitHub release でなく commit ベースなので自動更新せず現状を保持する。
  hb_block="$(extract_section homebrew)"
  [ -n "$hb_block" ] || die "pinned.toml: [homebrew] セクションが見つからない(保持できない)"

  new_content="$(
    cat <<'EOF'
# Pinned bootstrap binaries (supply-chain trust anchor).
#
# chezmoi / mise 本体のバージョンと sha256、Homebrew 公式 install.sh の commit/sha256 を
# 固定する。人間がレビューして記録した値が信頼の起点。bootstrap.sh /
# installer/chezmoi-steps/homebrew.sh が読み込む。
# (Nerd Fonts は home/.chezmoiexternal.toml.tmpl に移行済み。ここでは扱わない。)
#
#   - version: GitHub Releases のタグ (先頭 'v' は付けない)
#   - sha256_<os>_<arch>: そのプラットフォーム向け .tar.gz の sha256 (lowercase hex 64桁)
#
# 各 tarball の SHA-256 は以下の checksums ファイルと照合する。
# chezmoi は installer/keys/chezmoi_cosign.pub で checksums ファイルの署名を毎回検証する。
# mise は各 tarball の GitHub artifact attestation でソースのタグと署名元の release.yml を検証する。
#   chezmoi: https://github.com/twpayne/chezmoi/releases/download/v<ver>/chezmoi_<ver>_checksums.txt
#   mise:    https://github.com/jdx/mise/releases/download/v<ver>/SHASUMS256.txt
#
# chezmoi / mise セクションは update-pins.sh が release-age ポリシーを尊重して自動生成する
# ([homebrew] は commit ベースなので自動更新せず保持される)。手で書き換える場合も必ず
# tarball に同じ検証を行い、Homebrew はレビュー済みの commit と照合すること。
EOF
    printf '\n%s\n\n%s\n\n%s\n' "$cz_block" "$mise_block" "$hb_block"
  )"

  # D4: refuse to write a malformed file. Both sections, both version lines,
  # and all 8 platform sha keys must be present.
  validate_content "$new_content" || die "internal: generated pinned.toml failed validation (not written)"

  if [ "$DRY_RUN" -eq 1 ]; then
    info "--dry-run: proposed pinned.toml (diff vs current):"
    if command -v diff >/dev/null 2>&1; then
      diff -u "$PINNED" <(printf '%s\n' "$new_content") || true
    else
      printf '%s\n' "$new_content"
    fi
    return 0
  fi

  tmp="$(mktemp "${TMPDIR:-/tmp}/pinned.XXXXXX")" || die "mktemp failed"
  if printf '%s\n' "$new_content" > "$tmp" && mv "$tmp" "$PINNED"; then
    info "pinned.toml updated."
  else
    rm -f "$tmp"
    die "failed to write pinned.toml"
  fi
}

main "$@"
