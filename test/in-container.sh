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
# path_has "<PATH-value>" "<dir>"  -> 0 iff <dir> is a colon-segment of <PATH-value>
path_has() { case ":$1:" in *":$2:"*) return 0 ;; *) return 1 ;; esac; }
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

# chezmoi is a bootstrap trust anchor (installer/pinned.toml), NOT a mise tool —
# managing it in both places makes the mise copy shadow the bootstrap one on PATH
# and drift in version. It must therefore be absent from the mise config + lock.
# shellcheck disable=SC2016  # $1 is the inner bash -c positional, expanded there
ok_if "chezmoi NOT a mise tool (lockfile has no tools.chezmoi)" \
  bash -c '! grep -q "tools.chezmoi" "$1"' _ "$HOME/.config/mise/mise.lock"
# shellcheck disable=SC2016  # ditto: $1 belongs to the inner bash -c
ok_if "chezmoi NOT a mise tool (config has no chezmoi assignment)" \
  bash -c '! grep -qE "^[[:space:]]*(chezmoi|.aqua:twpayne/chezmoi.)[[:space:]]*=" "$1"' _ "$HOME/.config/mise/config.toml"

# mise install was skipped in smoke -> tools must be absent (proves the gate)
if [ "$LEVEL" = smoke ]; then
  ok_if "smoke: ripgrep not installed (mise install skipped)" \
    bash -c '! '"$MISE"' which rg >/dev/null 2>&1'
fi

# --- stage 3b: a fresh LOGIN shell must bootstrap PATH on its own --------------
# Reproduces the reported breakage. On a fresh machine the login PATH does NOT
# contain ~/.local/bin (where bootstrap installed mise+chezmoi) nor ~/bin (personal
# scripts). The shell's *login* profile must prepend them itself — and BEFORE it
# runs `mise activate`, because mise itself lives in ~/.local/bin. Get the order
# wrong and a bash login shell hits "mise: command not found" and is left with
# neither mise/chezmoi nor ~/.local/bin/~/bin on PATH (the symptom on the user's box).
section "stage 3b: fresh login shell bootstraps PATH"
# System dirs only — a realistic fresh-login PATH with no ~/.local/bin, no ~/bin.
readonly BARE_LOGIN_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# `bash -lc` sources ~/.bash_profile (login); -c keeps it non-interactive so there
# is no prompt/plugin noise to filter.
login_bash() { env -i HOME="$HOME" TERM=xterm SHELL=/bin/bash PATH="$BARE_LOGIN_PATH" bash -lc "$1" 2>/dev/null; }
# shellcheck disable=SC2016  # $PATH must expand inside the login shell, not here
login_path="$(login_bash 'printf %s "$PATH"')"
ok_if "bash login: ~/.local/bin on PATH" path_has "$login_path" "$HOME/.local/bin"
ok_if "bash login: ~/bin on PATH"        path_has "$login_path" "$HOME/bin"
ok_if "bash login: mise resolves"    login_bash 'command -v mise >/dev/null'
ok_if "bash login: chezmoi resolves" login_bash 'command -v chezmoi >/dev/null'

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

# --- stage 6: the one-shot ./install.sh entry point runs end-to-end ------------
# The stages above drove bootstrap + chezmoi by hand; a real fresh machine runs
# ./install.sh. Exercise it directly so the orchestration (bootstrap -> persist ->
# chezmoi init --apply -> closing guidance) doesn't regress. Idempotent here: the
# repo is already applied, so this is a no-op apply. No SSH / no TTY in the test,
# so the headless prompt is skipped and the run is non-interactive.
section "stage 6: ./install.sh end-to-end"
install_log="$(cd "$WORK" && DOTFILES_SKIP_MISE_INSTALL=1 ./install.sh 2>&1)"; install_rc=$?
ok_if "./install.sh exits 0" test "$install_rc" -eq 0
# shellcheck disable=SC2016  # $1 is the bash -c positional, expanded by that shell
ok_if "./install.sh prints closing guidance" \
  bash -c 'printf %s "$1" | grep -q "exec .* -l"' _ "$install_log"
# shellcheck disable=SC2016  # ditto: $1 belongs to the inner bash -c
ok_if "chained bootstrap suppresses the standalone 'Next:' hint" \
  bash -c '! printf %s "$1" | grep -q "^Next:"' _ "$install_log"
[ "$install_rc" -eq 0 ] || printf '%s\n' "$install_log" | tail -20

# install.sh must persist the source dir so *bare* chezmoi (chezmoi diff/apply,
# chezmoi doctor, the Makefile targets) resolves THIS repo. Without it, a fresh
# login falls back to the empty default ~/.local/share/chezmoi and every bare
# chezmoi command errors with "no such file or directory" (the reported symptom).
# .chezmoiroot=home means source-path is the repo's home/ subdir, not the root.
ok_if "bare chezmoi source-path resolves to the repo (.chezmoiroot applied)" \
  test "$("$CHEZMOI" source-path 2>/dev/null)" = "$WORK/home"
bare_diff="$("$CHEZMOI" diff 2>&1)"
if [ -z "$bare_diff" ]; then
  ok "bare chezmoi diff succeeds and is empty (source dir persisted)"
else
  bad "bare chezmoi diff failed or non-empty"
  printf '%s\n' "$bare_diff" | head -10
fi

summary
[ "$FAIL" -eq 0 ]
