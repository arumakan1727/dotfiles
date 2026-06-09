#!/usr/bin/env bash
# Update pinned.toml to the latest chezmoi / mise releases that satisfy the
# release-age policy (mirrors MISE_INSTALL_BEFORE / UV_EXCLUDE_NEWER: do not
# adopt a release younger than N days). Re-records the SHA-256 of each target
# platform's tarball from the upstream checksum file.
#
# USAGE:
#   ./update-pins.sh [--days N] [--dry-run] [--allow-downgrade]
#
#   --days N           release-age window in days (default: $INSTALL_BEFORE_DAYS or 7)
#   --dry-run          show what would change; do not write pinned.toml
#   --allow-downgrade  if the latest age-compliant release is OLDER than the
#                      current pin (i.e. the current pin violates the policy),
#                      downgrade to enforce it. Default: keep current pin.
#
# Requires (maintenance-time tools, NOT bootstrap): curl, jq, awk, date, sort.
# Uses GITHUB_TOKEN if set (avoids API rate limits).
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly PINNED="$SCRIPT_DIR/pinned.toml"

DAYS="${INSTALL_BEFORE_DAYS:-7}"
DRY_RUN=0
ALLOW_DOWNGRADE=0

die() { echo "[ERR] $*" >&2; exit 1; }
info() { echo "[*] $*"; }
warn() { echo "[WARN] $*" >&2; }

# Platforms recorded per tool (must match pinned.toml keys and the upstream
# asset naming). chezmoi: chezmoi_<ver>_<key>.tar.gz ; mise: mise-v<ver>-<key/_/->.tar.gz
readonly CHEZMOI_KEYS="darwin_arm64 darwin_amd64 linux_arm64 linux_amd64"
readonly MISE_KEYS="macos_arm64 macos_x64 linux_arm64 linux_x64"

parse_args() {
  while [ $# -gt 0 ]; do
    case "$1" in
      --days) shift; [ $# -gt 0 ] || die "--days requires a value"; DAYS="$1" ;;
      --days=*) DAYS="${1#*=}" ;;
      --dry-run) DRY_RUN=1 ;;
      --allow-downgrade) ALLOW_DOWNGRADE=1 ;;
      -h | --help) sed -n '2,18p' "${BASH_SOURCE[0]}"; exit 0 ;;
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
  for t in curl jq awk date; do
    command -v "$t" >/dev/null 2>&1 || die "required tool not found: $t"
  done
}

curl_get() { curl -fsSL --proto '=https' --tlsv1.2 "$@"; }

gh_api() { # <path> -> JSON on stdout
  local url="https://api.github.com/$1"
  if [ -n "${GITHUB_TOKEN:-}" ]; then
    curl_get -H "Authorization: Bearer $GITHUB_TOKEN" \
             -H "X-GitHub-Api-Version: 2022-11-28" "$url"
  else
    curl_get "$url"
  fi
}

# Newest non-draft, non-prerelease release at least $DAYS old. Prints tag_name
# (may carry a leading 'v'); empty if none.
pick_release() { # <owner/repo>
  local repo="$1" now cutoff
  now="$(date +%s)"
  cutoff=$((now - DAYS * 86400))
  gh_api "repos/$repo/releases?per_page=50" | jq -r --argjson cutoff "$cutoff" '
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

# TRUST MODEL (read before extending): the recorded sha256 comes from the
# release's own checksums file. This pins exact bytes but does NOT
# independently attest them — there is no GPG/cosign signature check here.
# Also note `published_at` is the *first* publish time; a maintainer can edit a
# release (replace assets) without changing it, so age alone is not a guarantee
# of immutability. For a personal dotfiles trust model this is accepted; adding
# signature verification (chezmoi: .sig, mise: SHASUMS256.asc/.minisig) would be
# the next hardening step.

# Extract one asset sha256 from a checksum file body on stdin.
# Matches "<sha>  <asset>" or "<sha>  ./<asset>".
sha_for_asset() { # <asset_name>
  awk -v a="$1" '$2==a || $2=="./"a { print $1; found=1; exit } END { exit !found }'
}

# Print "<key> <sha>" lines for chezmoi at version $1; non-zero on any miss.
fetch_chezmoi_sums() { # <ver>
  local ver="$1" body key asset sha
  body="$(curl_get "https://github.com/twpayne/chezmoi/releases/download/v${ver}/chezmoi_${ver}_checksums.txt")" \
    || { warn "failed to download chezmoi checksums for $ver"; return 1; }
  for key in $CHEZMOI_KEYS; do
    asset="chezmoi_${ver}_${key}.tar.gz"
    sha="$(printf '%s\n' "$body" | sha_for_asset "$asset")" \
      || { warn "chezmoi: no checksum for $asset"; return 1; }
    printf '%s %s\n' "sha256_${key}" "$sha"
  done
}

# Print "<key> <sha>" lines for mise at version $1; non-zero on any miss.
fetch_mise_sums() { # <ver>
  local ver="$1" body key asset sha
  body="$(curl_get "https://github.com/jdx/mise/releases/download/v${ver}/SHASUMS256.txt")" \
    || { warn "failed to download mise checksums for $ver"; return 1; }
  for key in $MISE_KEYS; do
    asset="mise-v${ver}-$(printf '%s' "$key" | tr '_' '-').tar.gz"
    sha="$(printf '%s\n' "$body" | sha_for_asset "$asset")" \
      || { warn "mise: no checksum for $asset"; return 1; }
    printf '%s %s\n' "sha256_${key}" "$sha"
  done
}

# Current pinned version for a section (empty if absent).
current_version() { # <section>
  awk -v s="$1" '
    /^[[:space:]]*\[/ { l=$0; gsub(/[][[:space:]]/,"",l); cur=l; next }
    cur==s {
      eq=index($0,"="); if(eq<=0) next
      k=substr($0,1,eq-1); gsub(/[[:space:]]/,"",k)
      if(k=="version" && match($0,/"[^"]*"/)){ print substr($0,RSTART+1,RLENGTH-2); exit }
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

# Decide the version to record and emit the section block on stdout.
# Echoes a human note to stderr. Returns 0 always (keeps current on no-op).
resolve_section() { # <section> <fetch_fn>
  local section="$1" fetch_fn="$2" cur target
  cur="$(current_version "$section")"
  target="$(pick_release "$(repo_of "$section")")"
  [ -n "$target" ] || die "$section: no release found within the $DAYS-day age policy"
  target="${target#v}" # normalise leading v

  if [ "$target" = "$cur" ]; then
    info "$section: up to date (pinned $cur, latest age-compliant $target)" >&2
    extract_section "$section"
    return 0
  fi
  if is_downgrade "$cur" "$target"; then
    if [ "$ALLOW_DOWNGRADE" -eq 1 ]; then
      warn "$section: DOWNGRADE $cur -> $target (current pin is newer than the ${DAYS}-day policy)"
    else
      warn "$section: current pin $cur is NEWER than latest age-compliant $target; keeping $cur (use --allow-downgrade to enforce policy)"
      extract_section "$section"
      return 0
    fi
  else
    info "$section: update $cur -> $target" >&2
  fi

  local lines
  lines="$("$fetch_fn" "$target")" || die "$section: failed to fetch checksums for $target"
  {
    printf '[%s]\n' "$section"
    printf 'version            = "%s"\n' "$target"
    printf '%s\n' "$lines" | awk '{ printf "%-18s = \"%s\"\n", $1, $2 }'
  }
}

repo_of() { # <section> -> owner/repo
  case "$1" in
    chezmoi) echo "twpayne/chezmoi" ;;
    mise) echo "jdx/mise" ;;
    *) die "unknown section: $1" ;;
  esac
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

  info "release-age policy: >= ${DAYS} days old"

  local cz_block mise_block hb_block new_content tmp
  cz_block="$(resolve_section chezmoi fetch_chezmoi_sums)"
  mise_block="$(resolve_section mise fetch_mise_sums)"
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
# 値の出所 (照合先 checksums ファイル):
#   chezmoi: https://github.com/twpayne/chezmoi/releases/download/v<ver>/chezmoi_<ver>_checksums.txt
#   mise:    https://github.com/jdx/mise/releases/download/v<ver>/SHASUMS256.txt
#
# chezmoi / mise セクションは update-pins.sh が release-age ポリシーを尊重して自動生成する
# ([homebrew] は commit ベースなので自動更新せず保持される)。手で書き換える場合も必ず
# 上記 checksums ファイル / レビュー済み commit と照合すること。
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
  # Explicit cleanup on failure (no EXIT trap -> no local-scope/`set -u` pitfalls).
  if printf '%s\n' "$new_content" > "$tmp" && mv "$tmp" "$PINNED"; then
    info "pinned.toml updated."
  else
    rm -f "$tmp"
    die "failed to write pinned.toml"
  fi
}

main "$@"
