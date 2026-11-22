#!/usr/bin/env bash
# Library: toml_get — read one value from installer/pinned.toml.
#
# USAGE (source this file; do NOT execute it):
#     . "<dir>/lib/toml_get.sh"
#     toml_get <file> <section> <key>   # prints the value (empty if not found)
#
# Minimal reader for the restricted grammar used by pinned.toml: flat
# `key = "value"` lines grouped under `[section]` headers, '#' comments. No
# nested tables, arrays, or multiline values. Section and key names are matched
# LITERALLY (not as regex), so metacharacters such as '-' are safe.
toml_get() {
  local file="$1" section="$2" key="$3"
  awk -v want_section="$section" -v want_key="$key" '
    # skip blank lines and comments
    /^[[:space:]]*#/ { next }
    /^[[:space:]]*$/ { next }
    # section header: [name]
    /^[[:space:]]*\[/ {
      line = $0
      gsub(/[][[:space:]]/, "", line)   # strip [ ] and spaces -> bare name
      cur = line
      next
    }
    # key line within the wanted section: split on first "=", compare key literally
    cur == want_section {
      eq = index($0, "=")
      if (eq > 0) {
        k = substr($0, 1, eq - 1)
        gsub(/[[:space:]]/, "", k)       # trim all spaces from key token
        if (k == want_key) {
          rest = substr($0, eq + 1)
          if (match(rest, /"[^"]*"/)) {   # value is the first quoted string
            print substr(rest, RSTART + 1, RLENGTH - 2)
            exit
          }
        }
      }
    }
  ' "$file"
}
