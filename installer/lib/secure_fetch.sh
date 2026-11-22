#!/usr/bin/env bash
# Library: secure_fetch — download a file over HTTPS and verify its SHA-256
# against a caller-supplied expected value before accepting it.
#
# USAGE (source this file; do NOT execute it):
#     . "<dir>/lib/secure_fetch.sh"
#     secure_fetch <url> <expected_sha256> <dest_path>
#
# Returns:
#     0  success — verified file is at <dest_path>
#     1  runtime failure (download error / checksum mismatch / io error)
#     2  usage error (bad arguments)
# On any failure, no partial file is left at <dest_path> and the temp file
# is removed.
#
# Dependencies: curl, and one of {sha256sum, shasum}. No GPG/minisign needed
# for this layer (that is optional defense-in-depth handled elsewhere).
#
# NOTE: verifying against a checksum that you stored/reviewed out-of-band
# (e.g. committed in pinned.toml) is the real trust anchor. Verifying against
# a checksums file fetched from the *same* release only catches corruption.

# Run curl "$@", retrying transient failures with exponential backoff
# (2s, 4s, 8s; SECURE_FETCH_ATTEMPTS attempts in total, default 4):
#   - network-level errors curl's own --retry does not cover: DNS, connect,
#     TLS handshake (exit 35, seen against GitHub's release CDN), timeouts,
#     truncated or reset transfers, HTTP/2 stream errors;
#   - HTTP 408/429/5xx, via curl's --retry inside each attempt.
# Other HTTP errors (a 404 under -f) fail at once. Some curl builds report an
# HTTP error under -f over HTTP/2 as a receive error (exit 56) instead of 22, so
# an HTTP error is recognised by curl's "returned error: <status>" message (on
# stderr with -S); if that wording ever changes, the cost is extra retries.
# stdout is buffered and printed only for the attempt that succeeds, so a
# write-out (-w) from a failed attempt never reaches the caller; download real
# content with -o.
_sf_curl() {
  local attempt=1 max="${SECURE_FETCH_ATTEMPTS:-4}" delay=2 rc out errf
  errf="$(mktemp "${TMPDIR:-/tmp}/sf_curl.XXXXXX")" || return 1
  while :; do
    # `&& rc=0 || rc=$?` keeps curl's status (an `if` would reset $? to 0) and
    # is safe under the callers' `set -e`.
    out="$(curl --retry 2 --retry-delay 2 "$@" 2>"$errf")" && rc=0 || rc=$?
    cat "$errf" >&2
    if [ "$rc" -eq 0 ]; then
      rm -f -- "$errf"
      printf '%s' "$out"
      return 0
    fi
    case "$rc" in
      5 | 6 | 7 | 16 | 18 | 28 | 35 | 52 | 55 | 56 | 92) ;; # transient
      *) rm -f -- "$errf"; return "$rc" ;;
    esac
    if grep -q 'returned error: [0-9]' "$errf" || [ "$attempt" -ge "$max" ]; then
      rm -f -- "$errf"
      return "$rc"
    fi
    echo "secure_fetch: curl failed (exit $rc), retrying in ${delay}s ($attempt/$((max - 1)))" >&2
    sleep "$delay"
    attempt=$((attempt + 1))
    delay=$((delay * 2))
  done
}

# Print the lowercase-hex SHA-256 of a file (hash only, no filename).
_sf_sha256() {
  local file="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$file" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$file" | awk '{print $1}'
  else
    echo "secure_fetch: neither 'sha256sum' nor 'shasum' is available" >&2
    return 1
  fi
}

secure_fetch() {
  local url="${1-}" want="${2-}" dest="${3-}"

  # --- argument validation (before creating any temp file) ---
  if [ -z "$url" ] || [ -z "$want" ] || [ -z "$dest" ]; then
    echo "secure_fetch: usage: secure_fetch <url> <expected_sha256> <dest_path>" >&2
    return 2
  fi
  # Normalise expected hash to lowercase and validate shape.
  want="$(printf '%s' "$want" | tr '[:upper:]' '[:lower:]')"
  if [ "${#want}" -ne 64 ] || printf '%s' "$want" | grep -q '[^0-9a-f]'; then
    echo "secure_fetch: expected_sha256 must be 64 lowercase hex chars: '$want'" >&2
    return 2
  fi

  # --- download to a temp file ---
  local tmp
  tmp="$(mktemp "${TMPDIR:-/tmp}/secure_fetch.XXXXXX")" || {
    echo "secure_fetch: failed to create temp file" >&2
    return 1
  }

  if ! _sf_curl -fsSL --proto '=https' --tlsv1.2 "$url" -o "$tmp"; then
    echo "secure_fetch: download failed: $url" >&2
    rm -f "$tmp"
    return 1
  fi

  # --- verify ---
  local got
  if ! got="$(_sf_sha256 "$tmp")"; then
    rm -f "$tmp"
    return 1
  fi
  got="$(printf '%s' "$got" | tr '[:upper:]' '[:lower:]')"

  if [ "$got" != "$want" ]; then
    echo "secure_fetch: SHA-256 MISMATCH for $url" >&2
    echo "  expected: $want" >&2
    echo "  actual:   $got" >&2
    rm -f "$tmp"
    return 1
  fi

  # --- move verified file into place ---
  if ! mkdir -p "$(dirname "$dest")"; then
    rm -f "$tmp"
    return 1
  fi
  # mv may fail across filesystems (TMPDIR vs dest); fall back to cp.
  if ! mv "$tmp" "$dest" 2>/dev/null; then
    if ! cp "$tmp" "$dest"; then
      echo "secure_fetch: failed to write $dest" >&2
      rm -f "$tmp"
      return 1
    fi
    rm -f "$tmp"
  fi
  return 0
}
