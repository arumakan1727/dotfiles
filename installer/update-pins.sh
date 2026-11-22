#!/usr/bin/env bash
# Update pinned.toml to the latest chezmoi / mise / Claude Code / Codex releases
# that satisfy the release-age policy (mirrors mise minimum_release_age /
# UV_EXCLUDE_NEWER: do not adopt a release younger than N days).
#
#   chezmoi:     always verify the checksums signature with the repo-pinned cosign key.
#   mise:        verify each tarball's GitHub artifact attestation against the
#                release tag and release.yml workflow.
#   claude-code: take the "stable" channel version, verify manifest.json with the
#                repo-pinned GPG key, and apply the age policy to the version's
#                anthropics/claude-code GitHub release date. The signed manifest
#                vouches for every binary, so none is downloaded.
#   codex:       cross-check codex-package_SHA256SUMS with the digests GitHub and
#                releases.openai.com report for each asset, then verify the Linux
#                tarballs' Sigstore bundles (cosign, release workflow identity) and
#                every Mach-O file in the macOS tarballs (codesign, OpenAI team ID).
#                Without cosign and codesign (i.e. off macOS), a changed [codex]
#                pin is kept as is rather than written half-verified.
# For changed chezmoi / mise / codex sections, every tarball is downloaded and its
# SHA-256 checked.
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
# Maintenance tools: curl, gh, jq, openssl, gpg, awk, date, and sha256sum or
# shasum. A changed [codex] pin also needs cosign, codesign and file, so run it on
# macOS with cosign active (mise x aqua:sigstore/cosign@<ver> -- ./update-pins.sh).
# Authenticate gh with GH_TOKEN, GITHUB_TOKEN, or gh auth login.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly PINNED="$SCRIPT_DIR/pinned.toml"
# From twpayne/chezmoi's assets/cosign/cosign.pub (also shipped as chezmoi_cosign.pub
# in v2.74.1). Rotation requires a manual, reviewed change to installer/keys/chezmoi_cosign.pub.
readonly CHEZMOI_COSIGN_KEY="$SCRIPT_DIR/keys/chezmoi_cosign.pub"
# Anthropic's Claude Code release signing key, from
# https://downloads.claude.ai/keys/claude-code.asc. The fingerprint is the one
# documented at https://code.claude.com/docs/en/setup ("Binary integrity and
# code signing"). Rotation requires a manual, reviewed change to both.
readonly CLAUDE_GPG_KEY="$SCRIPT_DIR/keys/claude-code.asc"
readonly CLAUDE_GPG_FPR="31DDDE24DDFAB679F42D7BD2BAA929FF1A7ECACE"
readonly CLAUDE_RELEASES_URL="https://downloads.claude.ai/claude-code-releases"
# Release notes repo; its release dates are the age clock for Claude Code.
readonly CLAUDE_GITHUB_REPO="anthropics/claude-code"
# Apple Developer ID team of "OpenAI OpCo, LLC", which signs every Mach-O file in
# the macOS codex packages.
readonly CODEX_TEAM_ID="2DC432GLL2"
# OpenAI's own release mirror; the official installer prefers it over GitHub.
readonly CODEX_RELEASES_URL="https://releases.openai.com/codex/releases"

# shellcheck source-path=SCRIPTDIR source=lib/secure_fetch.sh
. "$SCRIPT_DIR/lib/secure_fetch.sh"
# shellcheck source-path=SCRIPTDIR source=lib/toml_get.sh
. "$SCRIPT_DIR/lib/toml_get.sh"

DAYS="${INSTALL_BEFORE_DAYS:-7}"
DRY_RUN=0
ALLOW_DOWNGRADE=0

die() { echo "[ERR] $*" >&2; exit 1; }
info() { echo "[*] $*"; }
warn() { echo "[WARN] $*" >&2; }

# Platforms recorded per tool (must match pinned.toml keys and the upstream
# asset naming).
#   chezmoi:     chezmoi_<ver>_<key>.tar.gz
#   mise:        mise-v<ver>-<key with _ -> ->.tar.gz
#   claude-code: manifest.json platforms["<key with _ -> ->"]
#   codex:       codex-package-<target>.tar.gz, key = sha256_<target with - -> _>
readonly -a CHEZMOI_KEYS=(darwin_arm64 darwin_amd64 linux_arm64 linux_amd64)
readonly -a MISE_KEYS=(macos_arm64 macos_x64 linux_arm64 linux_x64)
readonly -a CLAUDE_KEYS=(darwin_arm64 darwin_x64 linux_arm64 linux_x64)
readonly -a CODEX_TARGETS=(aarch64-apple-darwin x86_64-apple-darwin aarch64-unknown-linux-musl x86_64-unknown-linux-musl)

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
  for t in curl gh jq openssl gpg awk date; do
    command -v "$t" >/dev/null 2>&1 || die "required tool not found: $t"
  done
  command -v sha256sum >/dev/null 2>&1 || command -v shasum >/dev/null 2>&1 \
    || die "required tool not found: sha256sum or shasum"
}

curl_get() { curl -fsSL --proto '=https' --tlsv1.2 "$@"; }

# Newest (by version) non-draft, non-prerelease release at least $DAYS old whose
# tag is <tag_prefix><dotted numeric version>. Prints the version without the
# prefix; empty if none. Sorting by version, not publish time, keeps a late patch
# of an older line (e.g. codex 0.169.1 after 0.170.0) from winning.
#
# Uses the GraphQL API for tag/date metadata only: the REST listing embeds every
# asset (~200 per codex release) and times out on large pages. Creation order
# says nothing about version order (a late patch of an older line), so every
# page is read and the candidates are compared together. Metadata pages are
# small: even codex's ~1,500 releases take about 15 requests.
readonly PICK_MAX_PAGES=100 # safety stop only; hit means something is wrong
pick_release() { # <owner/repo> <tag_prefix>
  local repo="$1" prefix="$2" now cutoff page=0 cursor="" out
  local -a args files=()
  now="$(date +%s)"
  cutoff=$((now - DAYS * 86400))
  while :; do
    page=$((page + 1))
    [ "$page" -le "$PICK_MAX_PAGES" ] \
      || { echo "pick_release: $repo has more than $PICK_MAX_PAGES pages of releases" >&2; return 1; }
    out="$work_dir/releases-${repo//\//_}-$page.json"
    args=(-f "owner=${repo%%/*}" -f "name=${repo#*/}")
    [ -z "$cursor" ] || args+=(-f "cursor=$cursor")
    # shellcheck disable=SC2016  # $owner etc. are GraphQL variables, not shell
    gh api graphql --hostname github.com "${args[@]}" -f query='
      query($owner: String!, $name: String!, $cursor: String) {
        repository(owner: $owner, name: $name) {
          releases(first: 100, after: $cursor, orderBy: {field: CREATED_AT, direction: DESC}) {
            pageInfo { hasNextPage endCursor }
            nodes { tagName publishedAt isPrerelease isDraft }
          }
        }
      }' > "$out" || return 1
    jq -e '.data.repository.releases.nodes | type == "array"' "$out" >/dev/null \
      || { echo "pick_release: unexpected GraphQL response for $repo: $(head -c 300 "$out")" >&2; return 1; }
    files+=("$out")
    jq -e '.data.repository.releases.pageInfo.hasNextPage' "$out" >/dev/null || break
    cursor="$(jq -r '.data.repository.releases.pageInfo.endCursor' "$out")"
  done
  jq -s -r --argjson cutoff "$cutoff" --arg prefix "$prefix" '
    map(.data.repository.releases.nodes) | add // []
    | [ .[]
        | select(.isDraft | not)
        | select(.isPrerelease | not)
        | select(.publishedAt != null)             # skip releases lacking a publish date
        | select(.tagName | startswith($prefix))
        | { v: (.tagName | ltrimstr($prefix)), t: (.publishedAt | fromdateiso8601) }
        | select(.v | test("^[0-9]+(\\.[0-9]+)+$"))
        | select(.t <= $cutoff)
      ]
    | sort_by(.v | split(".") | map(tonumber)) | last | .v // empty' "${files[@]}"
}

# Publication time (epoch seconds) of the GitHub release <tag>; empty if there
# is no such release or the lookup fails. On HTTP errors gh still prints the
# error body on stdout, so only an all-digit result counts.
release_published_at() { # <owner/repo> <tag>
  local out
  out="$(gh api --hostname github.com "repos/$1/releases/tags/$2" \
    --jq '.published_at // empty | fromdateiso8601' 2>/dev/null)" || return 0
  [[ "$out" =~ ^[0-9]+$ ]] && printf '%s\n' "$out"
  return 0
}

# Extract one asset sha256 from a checksum file body on stdin.
# Matches "<sha>  <asset>" or "<sha>  ./<asset>".
sha_for_asset() { # <asset_name>
  awk -v a="$1" '$2==a || $2=="./"a { print $1; found=1; exit } END { exit !found }'
}

# Current pinned value for a section and key (empty if absent).
pinned_value() { # <section> <key>
  toml_get "$PINNED" "$1" "$2"
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
# older macOS). Valid for chezmoi (2.70.5), mise (2026.6.1), Claude Code
# (2.1.323) and Codex (0.169.0) style versions.
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

# Apply the downgrade policy to a candidate version. Prints the version to pin.
decide_target() { # <section> <current> <candidate>
  local section="$1" cur="$2" target="$3"
  if is_downgrade "$cur" "$target"; then
    if [ "$ALLOW_DOWNGRADE" -eq 1 ]; then
      warn "$section: DOWNGRADE $cur -> $target (current pin is newer than the ${DAYS}-day policy)"
    else
      warn "$section: current pin $cur is NEWER than latest age-compliant $target; keeping $cur (use --allow-downgrade to enforce policy)"
      target="$cur"
    fi
  elif [ "$target" != "$cur" ]; then
    info "$section: update ${cur:-(none)} -> $target" >&2
  fi
  printf '%s\n' "$target"
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
  target="$(pick_release "$repo" v)" || die "$section: release lookup failed"
  [ -n "$target" ] || die "$section: no release found within the $DAYS-day age policy"
  target="$(decide_target "$section" "$cur" "$target")"

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

# Fail unless <signature> is a valid signature over <manifest> by the pinned key.
verify_claude_manifest() { # <manifest> <signature>
  local gnupghome="$work_dir/gnupg" status
  mkdir -p "$gnupghome"
  chmod 700 "$gnupghome"
  GNUPGHOME="$gnupghome" gpg --batch --quiet --import "$CLAUDE_GPG_KEY" 2>/dev/null \
    || die "claude-code: failed to import $CLAUDE_GPG_KEY"
  status="$(GNUPGHOME="$gnupghome" gpg --batch --status-fd 1 --verify "$2" "$1" 2>/dev/null)" \
    || die "claude-code: invalid signature on ${1##*/}"
  # VALIDSIG <signing-key fpr> ... <primary-key fpr>: require the pinned primary key.
  printf '%s\n' "$status" \
    | awk -v fpr="$CLAUDE_GPG_FPR" '$1=="[GNUPG:]" && $2=="VALIDSIG" && $NF==fpr { ok=1 } END { exit !ok }' \
    || die "claude-code: ${1##*/} is not signed by $CLAUDE_GPG_FPR"
  info "${1##*/}: verified signature with the pinned GPG key"
}

# Emit the [claude-code] section on stdout. Diagnostics go to stderr.
resolve_claude_code() {
  local section=claude-code cur target manifest sig published
  cur="$(pinned_value "$section" version)"
  # The channel pointer is unsigned; the signed manifest below binds the version.
  target="$(curl_get "$CLAUDE_RELEASES_URL/stable")" || die "$section: failed to fetch the stable channel version"
  [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "$section: invalid stable channel version: '$target'"
  target="$(decide_target "$section" "$cur" "$target")"

  manifest="$work_dir/claude-code-manifest.json"
  sig="$manifest.sig"
  curl_get "$CLAUDE_RELEASES_URL/$target/manifest.json" -o "$manifest" || die "$section: failed to fetch manifest.json for $target"
  curl_get "$CLAUDE_RELEASES_URL/$target/manifest.json.sig" -o "$sig" || die "$section: failed to fetch manifest.json.sig for $target"
  verify_claude_manifest "$manifest" "$sig" >&2
  jq -e --arg v "$target" '.version == $v' "$manifest" >/dev/null || die "$section: manifest.json is not for version $target"

  local key plat sha pinned_sha width=7 changed=0
  local -a sums
  [ "$target" = "$cur" ] || changed=1
  for key in "${CLAUDE_KEYS[@]}"; do
    plat="${key//_/-}"
    sha="$(jq -r --arg p "$plat" '.platforms[$p].checksum // empty' "$manifest")"
    [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || die "$section: manifest.json has no valid checksum for $plat"
    sums+=("$sha")
    pinned_sha="$(pinned_value "$section" "sha256_$key")"
    [ "$sha" = "$pinned_sha" ] || changed=1
    [ $((${#key} + 7)) -le "$width" ] || width=$((${#key} + 7))
  done

  if [ "$changed" -eq 0 ]; then
    info "$section $target: version and all checksums unchanged" >&2
    extract_section "$section"
    return
  fi

  # Age policy, for a new version and for new hashes under the same version
  # alike: measured from the public GitHub release, which comes hours after the
  # manifest's buildDate. The signed manifest stays the source of the hashes.
  published="$(release_published_at "$CLAUDE_GITHUB_REPO" "v$target")"
  if [ -z "$published" ] || [ $(($(date +%s) - published)) -lt $((DAYS * 86400)) ]; then
    [ -n "$cur" ] || die "$section: $target has no GitHub release at least $DAYS days old, and nothing is pinned yet"
    warn "$section: $target has no GitHub release at least $DAYS days old; keeping $cur"
    extract_section "$section"
    return
  fi

  local i=0
  printf '[%s]\n' "$section"
  printf '%-*s = "%s"\n' "$width" version "$target"
  for key in "${CLAUDE_KEYS[@]}"; do
    printf '%-*s = "%s"\n' "$width" "sha256_$key" "${sums[i]}"
    i=$((i + 1))
  done
}

# Can this machine run every provenance check resolve_codex needs? cosign is run
# rather than looked up: an inactive mise shim is on PATH but fails. codesign
# exists on macOS only.
codex_verifiers_available() {
  cosign version >/dev/null 2>&1 && command -v codesign >/dev/null 2>&1 && command -v file >/dev/null 2>&1
}

# Is <file> a regular file with a valid code signature chaining to Apple and
# issued to OpenAI's Developer ID team?
verify_team_signature() { # <file>
  [ -f "$1" ] && codesign --verify --strict \
    -R="anchor apple generic and certificate leaf[subject.OU] = \"$CODEX_TEAM_ID\"" "$1" >&2
}

# Verify where a downloaded codex package came from. Linux tarballs carry a
# keyless Sigstore bundle from the release workflow that covers the whole
# tarball. macOS tarballs have no bundle, but every Mach-O file in them (the
# CLI, its helpers, rg, the voice dylibs) is signed with OpenAI's Developer ID.
verify_codex_package() { # <tarball> <target> <version> <release download URL>
  local file="$1" target="$2" ref="refs/tags/rust-v$3" url="$4" dir list f kind n=0
  case "$target" in
    *-linux-*)
      curl_get "$url/${file##*/}.sigstore" -o "$file.sigstore" || die "codex: failed to fetch ${file##*/}.sigstore"
      cosign verify-blob --bundle "$file.sigstore" \
        --certificate-identity "https://github.com/openai/codex/.github/workflows/rust-release.yml@$ref" \
        --certificate-oidc-issuer "https://token.actions.githubusercontent.com" "$file" >&2 \
        || die "codex: Sigstore verification failed for ${file##*/}"
      info "${file##*/}: verified Sigstore bundle (rust-release.yml@$ref)"
      ;;
    *-apple-darwin)
      dir="$work_dir/codesign-$target"
      list="$dir.files"
      mkdir -p "$dir"
      tar -xzf "$file" -C "$dir" || die "codex: failed to extract ${file##*/}"
      # The launcher must verify regardless of how `file` classifies it.
      verify_team_signature "$dir/bin/codex" || die "codex: bin/codex in ${file##*/} is missing or not signed by team $CODEX_TEAM_ID"
      # List to a file first so a find failure is not lost in a pipe.
      find "$dir" -type f -print0 > "$list" || die "codex: failed to list ${file##*/}"
      while IFS= read -r -d '' f; do
        kind="$(file -b "$f")" || die "codex: file(1) failed on ${f#"$dir"/}"
        case "$kind" in
          *Mach-O*) ;;
          *) continue ;;
        esac
        verify_team_signature "$f" || die "codex: ${f#"$dir"/} in ${file##*/} is not signed by team $CODEX_TEAM_ID"
        n=$((n + 1))
      done < "$list"
      rm -rf -- "$dir" "$list"
      info "${file##*/}: verified Developer ID signature (team $CODEX_TEAM_ID) on all $n Mach-O files"
      ;;
    *) die "codex: unknown target: $target" ;;
  esac
}

# Emit the [codex] section on stdout. Diagnostics go to stderr.
resolve_codex() {
  local section=codex repo=openai/codex cur target url sums meta mirror
  cur="$(pinned_value "$section" version)"
  target="$(pick_release "$repo" rust-v)" || die "$section: release lookup failed"
  [ -n "$target" ] || die "$section: no release found within the $DAYS-day age policy"
  target="$(decide_target "$section" "$cur" "$target")"
  [[ "$target" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]] || die "$section: invalid release version: $target"

  url="https://github.com/$repo/releases/download/rust-v$target"
  sums="$work_dir/codex-package_SHA256SUMS"
  meta="$work_dir/codex-release.json"
  mirror="$work_dir/codex-release-openai.json"
  curl_get "$url/codex-package_SHA256SUMS" -o "$sums" || die "$section: failed to fetch codex-package_SHA256SUMS"
  gh api --hostname github.com "repos/$repo/releases/tags/rust-v$target" > "$meta" \
    || die "$section: failed to fetch release metadata for rust-v$target"
  curl_get "$CODEX_RELEASES_URL/$target/release.json" -o "$mirror" \
    || die "$section: failed to fetch $CODEX_RELEASES_URL/$target/release.json"
  jq -e --arg tag "rust-v$target" '.tag_name == $tag' "$mirror" >/dev/null \
    || die "$section: releases.openai.com release.json is not for rust-v$target"

  local t key asset sha digest pinned_sha width=7 changed=0
  local -a sums_arr
  [ "$target" = "$cur" ] || changed=1
  for t in "${CODEX_TARGETS[@]}"; do
    asset="codex-package-$t.tar.gz"
    key="sha256_${t//-/_}"
    sha="$(sha_for_asset "$asset" < "$sums")" || die "codex-package_SHA256SUMS: missing $asset"
    [[ "$sha" =~ ^[0-9a-f]{64}$ ]] || die "codex-package_SHA256SUMS: invalid SHA-256 for $asset"
    # GitHub computes this digest itself when the asset is uploaded, so a SUMS
    # file that disagrees with the uploaded bytes is caught here. OpenAI's own
    # mirror must agree too, so a tampered GitHub release alone does not pass.
    digest="$(jq -r --arg a "$asset" '.assets[] | select(.name == $a) | .digest // empty' "$meta")"
    [ "$digest" = "sha256:$sha" ] \
      || die "$section: $asset: SHA256SUMS has $sha but GitHub reports ${digest:-no digest}"
    digest="$(jq -r --arg a "$asset" '.assets[] | select(.name == $a) | .digest // empty' "$mirror")"
    [ "$digest" = "sha256:$sha" ] \
      || die "$section: $asset: GitHub has $sha but releases.openai.com reports ${digest:-no digest}"
    sums_arr+=("$sha")
    pinned_sha="$(pinned_value "$section" "$key")"
    [ "$sha" = "$pinned_sha" ] || changed=1
    [ "${#key}" -le "$width" ] || width=${#key}
  done

  if [ "$changed" -eq 0 ]; then
    info "$section $target: version and all checksums unchanged; skipping tarball verification" >&2
    extract_section "$section"
    return
  fi

  # Never write hashes whose provenance was not checked: an unchanged pin skips
  # verification on the next run, so a skipped check would never be retried.
  if ! codex_verifiers_available; then
    [ -n "$cur" ] || die "$section: needs cosign and codesign (macOS) to verify a first pin"
    warn "$section: cosign and codesign (macOS) are required to verify $target; keeping $cur." \
      "Re-run on macOS with cosign, e.g. mise x aqua:sigstore/cosign@<ver> -- $0"
    extract_section "$section"
    return
  fi

  local i=0
  printf '[%s]\n' "$section"
  printf '%-*s = "%s"\n' "$width" version "$target"
  for t in "${CODEX_TARGETS[@]}"; do
    asset="codex-package-$t.tar.gz"
    sha="${sums_arr[i]}"
    TMPDIR="$work_dir" secure_fetch "$url/$asset" "$sha" "$work_dir/$asset" >&2 \
      || die "$section: download or checksum verification failed for $asset"
    info "$asset: verified SHA-256" >&2
    verify_codex_package "$work_dir/$asset" "$t" "$target" "$url" >&2
    rm -f -- "$work_dir/$asset" "$work_dir/$asset.sigstore" # ~200MB each; free space as we go
    printf '%-*s = "%s"\n' "$width" "sha256_${t//-/_}" "$sha"
    i=$((i + 1))
  done
}

# Fail unless <file> has every <key> in [<section>] and each sha256_* value is
# 64 lowercase hex chars (matching secure_fetch's check).
require_keys() { # <file> <section> <key>...
  local file="$1" section="$2" key value
  shift 2
  for key in "$@"; do
    value="$(toml_get "$file" "$section" "$key")"
    [ -n "$value" ] || return 1
    case "$key" in
      sha256_*) [[ "$value" =~ ^[0-9a-f]{64}$ ]] || return 1 ;;
    esac
  done
}

# Sanity-check generated content before it overwrites pinned.toml: every
# section with its version (or commit) and all platform keys must be present.
validate_content() { # <content>
  local file="$work_dir/pinned.candidate.toml" t
  local -a codex_keys=()
  for t in "${CODEX_TARGETS[@]}"; do codex_keys+=("sha256_${t//-/_}"); done
  printf '%s\n' "$1" > "$file"
  require_keys "$file" chezmoi version "${CHEZMOI_KEYS[@]/#/sha256_}" \
    && require_keys "$file" mise version "${MISE_KEYS[@]/#/sha256_}" \
    && require_keys "$file" homebrew install_commit install_sha256 \
    && require_keys "$file" claude-code version "${CLAUDE_KEYS[@]/#/sha256_}" \
    && require_keys "$file" codex version "${codex_keys[@]}"
}

main() {
  parse_args "$@"
  require_tools
  [ -f "$PINNED" ] || die "pinned.toml not found: $PINNED"
  [ -f "$CHEZMOI_COSIGN_KEY" ] || die "chezmoi: pinned cosign public key not found: $CHEZMOI_COSIGN_KEY"
  [ -f "$CLAUDE_GPG_KEY" ] || die "claude-code: pinned GPG public key not found: $CLAUDE_GPG_KEY"
  work_dir="$(mktemp -d "${TMPDIR:-/tmp}/update-pins.XXXXXX")" || die "mktemp failed"
  readonly work_dir
  trap 'rm -rf -- "$work_dir"' EXIT
  trap 'exit 129' HUP
  trap 'exit 130' INT
  trap 'exit 143' TERM

  info "release-age policy: >= ${DAYS} days old"

  local cz_block mise_block hb_block cc_block codex_block new_content tmp
  cz_block="$(resolve_section chezmoi twpayne/chezmoi "${CHEZMOI_KEYS[@]}")"
  mise_block="$(resolve_section mise jdx/mise "${MISE_KEYS[@]}")"
  # [homebrew] は GitHub release でなく commit ベースなので自動更新せず現状を保持する。
  hb_block="$(extract_section homebrew)"
  [ -n "$hb_block" ] || die "pinned.toml: [homebrew] セクションが見つからない(保持できない)"
  cc_block="$(resolve_claude_code)"
  codex_block="$(resolve_codex)"

  new_content="$(
    cat <<'EOF'
# Pinned binaries (supply-chain trust anchor).
#
# chezmoi / mise 本体、Claude Code / Codex CLI のバージョンと sha256、Homebrew 公式
# install.sh の commit/sha256 を固定する。人間がレビューして記録した値が信頼の起点。
# bootstrap.sh / installer/chezmoi-steps/{homebrew,claude-code,codex}.sh が読み込む。
# (Nerd Fonts は home/.chezmoiexternal.toml.tmpl に移行済み。ここでは扱わない。)
#
#   - version: リリースのバージョン (先頭 'v' / 'rust-v' は付けない)
#   - sha256_<platform>: そのプラットフォーム向け配布物の sha256 (lowercase hex 64桁)
#
# 各 sha256 の出所と検証:
#   chezmoi:     https://github.com/twpayne/chezmoi/releases/download/v<ver>/chezmoi_<ver>_checksums.txt
#                installer/keys/chezmoi_cosign.pub で checksums ファイルの署名を毎回検証する。
#   mise:        https://github.com/jdx/mise/releases/download/v<ver>/SHASUMS256.txt
#                各 tarball の GitHub artifact attestation でソースのタグと署名元の release.yml を検証する。
#   claude-code: https://downloads.claude.ai/claude-code-releases/<ver>/manifest.json
#                installer/keys/claude-code.asc で manifest の GPG 署名を検証する(stable チャネルの版)。
#                7日待機は anthropics/claude-code の GitHub release の公開日時で判定する。
#   codex:       https://github.com/openai/codex/releases/download/rust-v<ver>/codex-package_SHA256SUMS
#                GitHub と releases.openai.com の asset digest と突合し、Linux は Sigstore bundle、
#                macOS は全 Mach-O の Developer ID 署名を検証する。
#
# Claude Code / Codex は install-only: 未導入のマシンにだけこのピンで入れ、以降は各 CLI の
# 自己アップデートに任せる。ピンは新規マシンの初回導入の信頼の起点で、既存の導入は変えない。
#
# [homebrew] 以外は update-pins.sh が release-age ポリシーを尊重して自動生成する
# ([homebrew] は commit ベースなので自動更新せず保持される)。手で書き換える場合も必ず
# 同じ検証を行い、Homebrew はレビュー済みの commit と照合すること。
EOF
    printf '\n%s\n\n%s\n\n%s\n\n%s\n\n%s\n' "$cz_block" "$mise_block" "$hb_block" "$cc_block" "$codex_block"
  )"

  # Refuse to write a malformed file: every section and all platform keys must be present.
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
