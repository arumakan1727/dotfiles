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

  if ! curl -fsSL --proto '=https' --tlsv1.2 "$url" -o "$tmp"; then
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
