#!/usr/bin/env bash
# Runs INSIDE the test container (see test/Dockerfile / test/run.sh).
# Exercises the real fresh-machine flow against the mounted working tree and
# asserts the result. Exit status: 0 iff every assertion passed.
#
#   in-container.sh [smoke|full]
#
# smoke (default): bootstrap -> chezmoi init --apply (mise install skipped) ->
#                  structural verification. Fast; only downloads chezmoi+mise.
# full:            smoke + representative `mise install` + zsh/bash -i load.
#
# Deliberately no `set -e`: assertions must keep running after a failure so the
# summary reflects every check. Fatal setup steps are guarded explicitly.
set -uo pipefail

LEVEL="${1:-${TEST_LEVEL:-smoke}}"

readonly SRC=/src
readonly WORK="$HOME/dotfiles"
readonly CHEZMOI="$HOME/.local/bin/chezmoi"
readonly MISE="$HOME/.local/bin/mise"

# This container models a headless machine. Nerd Fonts are now chezmoi externals,
# so the DOTFILES_HEADLESS gate is evaluated on EVERY chezmoi invocation (apply
# AND diff) — not once at install. It must therefore be set process-wide here,
# exactly as a real headless host persistently exports DOTFILES_HEADLESS=1; if it
# were set only for `apply`, `chezmoi diff` would re-evaluate the external, want
# the fonts, and report a non-empty diff.
export DOTFILES_HEADLESS=1

PASS=0
FAIL=0
ok()      { printf '  \033[32m[PASS]\033[0m %s\n' "$1"; PASS=$((PASS + 1)); }
bad()     { printf '  \033[31m[FAIL]\033[0m %s\n' "$1"; FAIL=$((FAIL + 1)); }
section() { printf '\n\033[36m== %s ==\033[0m\n' "$1"; }
# ok_if "<desc>" <test-expression...>   e.g. ok_if "x exists" [ -f /x ]
ok_if()   { local d="$1"; shift; if "$@"; then ok "$d"; else bad "$d"; fi; }
fatal()   { printf '\n\033[31mFATAL:\033[0m %s\n' "$1" >&2; summary; exit 1; }

summary() {
  section "result ($LEVEL)"
  printf 'PASS=%d  FAIL=%d\n' "$PASS" "$FAIL"
}

# --- stage 0: copy the working tree (minus .git/tmp) into a writable dir ------
section "stage 0: copy working tree -> $WORK"
rm -rf "$WORK"
mkdir -p "$WORK"
if ( cd "$SRC" && tar --exclude=./.git --exclude=./tmp --exclude=./node_modules -cf - . ) \
   | ( cd "$WORK" && tar -xf - ); then
  ok "copied repo to $WORK"
else
  fatal "failed to copy repo from $SRC"
fi

# Expected pins (parsed from the same file the bootstrap trusts).
pinned="$WORK/installer/pinned.toml"
exp_chezmoi="$(awk -F'"' '/^\[chezmoi\]/{s=1} /^\[mise\]/{s=0} s&&/^[[:space:]]*version/{print $2; exit}' "$pinned")"
exp_mise="$(awk -F'"' '/^\[mise\]/{s=1} s&&/^[[:space:]]*version/{print $2; exit}' "$pinned")"
echo "  expected pins: chezmoi=$exp_chezmoi  mise=$exp_mise"

# --- stage 1: bootstrap (pinned + checksum-verified chezmoi & mise) -----------
section "stage 1: bootstrap"
if ! "$WORK/installer/bootstrap.sh"; then
  fatal "bootstrap script failed"
fi
export PATH="$HOME/.local/bin:$PATH"

ok_if "chezmoi binary installed" test -x "$CHEZMOI"
ok_if "mise binary installed" test -x "$MISE"

got_chezmoi="$("$CHEZMOI" --version 2>/dev/null | awk 'NR==1{v=$3; sub(/^v/,"",v); sub(/,.*/,"",v); print v}')"
got_mise="$("$MISE" --version 2>/dev/null | awk 'NR==1{print $1}')"
ok_if "chezmoi version == pinned ($exp_chezmoi, got ${got_chezmoi:-none})" test "$got_chezmoi" = "$exp_chezmoi"
ok_if "mise version == pinned ($exp_mise, got ${got_mise:-none})" test "$got_mise" = "$exp_mise"

# Idempotency: a second run must be a no-op (and not redownload/fail).
if "$WORK/installer/bootstrap.sh" >/tmp/bootstrap2.log 2>&1; then
  ok_if "bootstrap is idempotent (reports 'already installed')" grep -q "already installed" /tmp/bootstrap2.log
else
  bad "bootstrap second run failed"
fi

# --- stage 2: chezmoi init --apply (skip the heavy mise install in smoke) -----
# DOTFILES_HEADLESS=1 is exported process-wide above, so the Nerd Fonts external
# emits no entries (no ~hundreds-of-MB downloads; asserted below).
section "stage 2: chezmoi init --apply"
if ! DOTFILES_SKIP_MISE_INSTALL=1 "$CHEZMOI" init --apply --source="$WORK"; then
  fatal "chezmoi init --apply failed"
fi
ok "chezmoi init --apply completed"

# --- stage 3: structural verification -----------------------------------------
section "stage 3: verify materialized environment"

diff_out="$("$CHEZMOI" diff --source="$WORK" 2>&1)"
if [ -z "$diff_out" ]; then
  ok "chezmoi diff is empty (apply is a true no-op)"
else
  bad "chezmoi diff is NOT empty"
  printf '%s\n' "$diff_out" | head -40
fi

# real files (not symlinks), with known content
ok_if ".zshrc is a regular file (not a symlink)" test -f "$HOME/.zshrc"
ok_if ".zshrc is not a symlink" test ! -L "$HOME/.zshrc"
ok_if ".zshrc has expected content" grep -q "ensure_zcompiled" "$HOME/.zshrc"
ok_if ".zshenv materialized" test -f "$HOME/.zshenv"
ok_if ".bashrc materialized" test -f "$HOME/.bashrc"
ok_if ".gitconfig materialized" test -f "$HOME/.gitconfig"
ok_if ".config/mise/config.toml materialized" test -f "$HOME/.config/mise/config.toml"
ok_if ".config/nvim present" test -d "$HOME/.config/nvim"
ok_if ".p10k.zsh materialized" test -f "$HOME/.p10k.zsh"

# executable_ attribute honored
ok_if "bin/xkb_load_my_keymaps exists" test -f "$HOME/bin/xkb_load_my_keymaps"
ok_if "bin/xkb_load_my_keymaps is executable" test -x "$HOME/bin/xkb_load_my_keymaps"

# no source-name attribute leakage in the target tree
leak="$(find "$HOME/.config" "$HOME/bin" \
          \( -name 'dot_*' -o -name 'executable_*' -o -name 'private_*' \) 2>/dev/null)"
if [ -z "$leak" ]; then
  ok "no dot_/executable_/private_ source-name leakage in target"
else
  bad "source-name leakage found in target:"
  printf '%s\n' "$leak" | head -20
fi
ok_if "no literal dot_zshrc" test ! -e "$HOME/dot_zshrc"

# chezmoi meta files must not be materialized as targets
ok_if "no .chezmoiscripts" test ! -e "$HOME/.chezmoiscripts"
ok_if "no .chezmoiignore" test ! -e "$HOME/.chezmoiignore"
ok_if "no .chezmoiroot" test ! -e "$HOME/.chezmoiroot"

# run_onchange OS-gating: on Linux, Homebrew/macOS work must be skipped
ok_if "Homebrew NOT installed (run_onchange 10 is a no-op on Linux)" \
  bash -c '! command -v brew >/dev/null 2>&1'
ok_if "no Library tree on Linux (.chezmoiignore gate)" test ! -e "$HOME/Library"
ok_if "no .config/karabiner on Linux (.chezmoiignore gate)" test ! -e "$HOME/.config/karabiner"
ok_if "no .yabairc on Linux (.chezmoiignore gate)" test ! -e "$HOME/.yabairc"

# Nerd Fonts external must emit nothing on a headless machine (DOTFILES_HEADLESS=1)
# — no font tree downloaded/created.
ok_if "no fonts installed (chezmoi external skipped: headless)" test ! -e "$HOME/.local/share/fonts"

# rust was migrated from installer/rustup.sh into the mise lockfile.
ok_if "rust present in mise lockfile (migrated from rustup.sh)" \
  grep -q 'tools.rust' "$HOME/.config/mise/mise.lock"

# mise install was skipped in smoke -> tools must be absent (proves the gate)
if [ "$LEVEL" = smoke ]; then
  ok_if "smoke: ripgrep not installed (mise install skipped)" \
    bash -c '! '"$MISE"' which rg >/dev/null 2>&1'
fi

# --- stage 4 (full only): representative mise install --------------------------
if [ "$LEVEL" = full ]; then
  section "stage 4 (full): representative mise install"
  export MISE_YES=1
  "$MISE" trust --quiet "$HOME/.config/mise/config.toml" 2>/dev/null || true
  if "$MISE" install jq ripgrep fd; then
    ok "mise install jq ripgrep fd"
    # Verify each installed binary directly via `mise which` (resolves only that
    # tool). Avoid `mise exec`/bare invocation, which would try to set up the
    # WHOLE config env and auto-install every tool (incl. the archived neofetch).
    for t in jq rg fd; do
      bp="$("$MISE" which "$t" 2>/dev/null || true)"
      if [ -n "$bp" ] && "$bp" --version >/dev/null 2>&1; then
        ok "mise tool '$t' runs ($bp)"
      else
        bad "mise tool '$t' not runnable"
      fi
    done
  else
    bad "mise install of representative subset failed"
  fi

  section "stage 5 (full): interactive shell load"
  if bash -ic 'exit 0' </dev/null; then ok "bash -i loads cleanly"; else bad "bash -i failed"; fi
  # zsh self-installs sheldon + plugins on first load (needs network).
  if zsh -ic 'exit 0' </dev/null; then ok "zsh -i loads cleanly"; else bad "zsh -i failed"; fi
fi

summary
[ "$FAIL" -eq 0 ]
