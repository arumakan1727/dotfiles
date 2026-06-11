#!/usr/bin/env bash
# One-shot fresh-machine installer.
#
#   git clone <this repo> dotfiles && cd dotfiles && ./install.sh
#
# Thin wrapper that chains the two real steps so a clean machine is set up with
# a single command:
#   1. installer/bootstrap.sh  — fetch + sha256-verify pinned `chezmoi` & `mise`
#                                into ~/.local/bin (NO `curl | sh`; the trust
#                                anchor is installer/pinned.toml).
#   2. chezmoi init --apply     — materialize the dotfiles and run the apply-time
#                                steps (Homebrew/mise/macOS defaults, fonts, …).
#
# This adds NO new trust surface over `installer/bootstrap.sh` + `chezmoi init --apply`;
# it only removes the between-step PATH footgun by invoking the just-installed
# chezmoi by absolute path. Override the install dir with BIN_DIR=/somewhere.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

here="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
bin_dir="${BIN_DIR:-$HOME/.local/bin}"

# Y/n prompt, default Yes. Returns 0 on yes, 1 on an explicit no.
ask_yes_no() {
  local prompt="$1" ans=''
  printf '%s [Y/n]: ' "$prompt"
  read -r ans || ans=''
  case "$ans" in
    [nN] | [nN][oO]) return 1 ;;
    *) return 0 ;;
  esac
}

# On an SSH session, offer to run headless. DOTFILES_HEADLESS=1 means "this host
# has no display" and skips GUI-oriented setup. Today the only such step is the
# font external (home/.chezmoiexternal.toml.tmpl), which then emits nothing — so
# Nerd Fonts aren't fetched/installed — but the flag is meant to gate any future
# GUI-only steps too. Remote/server boxes have no display, so this saves the
# download + disk every apply.
#
# Two default-yes questions:
#   1. enable headless for THIS run (exports DOTFILES_HEADLESS=1 for the apply).
#   2. persist it to <repo>/mise.local.toml [env] so a later `chezmoi apply` run
#      from inside the repo also skips the GUI steps. Directory-scoped (not
#      global) and machine-local (gitignored) — what a per-host flag wants.
# Skipped entirely when not on a TTY, not over SSH, or DOTFILES_HEADLESS is
# already set in the environment (an explicit choice wins — don't ask).
offer_headless() {
  [ -n "${DOTFILES_HEADLESS:-}" ] && return 0
  [ -n "${SSH_CONNECTION:-}${SSH_TTY:-}${SSH_CLIENT:-}" ] || return 0
  [ -t 0 ] || return 0

  cat <<'MSG'

=== SSH 接続を検出しました ==============================================
headless モード (DOTFILES_HEADLESS=1) を有効にできます。

  画面を持たないリモート/サーバ機向けに、GUI 関連のセットアップを skip する
  モードです。GUI が無い環境では不要な取得・インストールを省けます。
  - 対象は GUI 用途の手順全般 (現状は Nerd Fonts の取得 / インストールのみ)。
    chezmoi apply / diff のたびに無効化され、帯域とディスクを節約します。
  - GUI ターミナルからこの機のフォント等を使いたい場合は無効 (n) のままに。
========================================================================
MSG

  if ! ask_yes_no "headless モードを有効にしますか?"; then
    return 0
  fi
  export DOTFILES_HEADLESS=1
  echo "[*] headless モードを有効にしました (この apply で GUI 手順 / 現状は fonts を skip)。"

  if ask_yes_no "この設定を $here/mise.local.toml に保存しますか? (今後 repo 内で実行する apply にも適用 / この機限定)"; then
    headless_persist=1
  fi
}

# Persist DOTFILES_HEADLESS=1 into the repo-local mise.local.toml [env] table.
# mise applies that [env] when the shell is activated inside the repo, so a later
# `chezmoi apply` from here inherits it and skips fonts. The file is machine-local
# (gitignored) and directory-scoped — no global state is touched.
#
# We let mise own the TOML (`mise config set`) so the key merges cleanly into any
# existing [env] table instead of risking a duplicate-table edit by hand. mise
# refuses to write/read an untrusted config, so trust it first; mise trusts by
# path, so the trust survives the edit and keeps future reads quiet. `-f` needs
# the file to exist, hence the touch.
persist_headless_to_mise() {
  local f="$here/mise.local.toml"
  [ -f "$f" ] || : >"$f"
  if "$bin_dir/mise" trust "$f" >/dev/null 2>&1 &&
    "$bin_dir/mise" config set -f "$f" --type string env.DOTFILES_HEADLESS 1; then
    echo "[*] $f に DOTFILES_HEADLESS=1 を保存しました (mise trust 済み)。"
  else
    # Fallback (e.g. trust write blocked): only the [env]-merge edge case is imperfect.
    grep -q 'DOTFILES_HEADLESS' "$f" 2>/dev/null || printf '[env]\nDOTFILES_HEADLESS = "1"\n' >>"$f"
    echo "[!] mise 経由の保存に失敗。$f に直接書き込みました。'mise trust $f' を確認してください。"
  fi
}

headless_persist=0
offer_headless

# Tell bootstrap it's being chained: install.sh owns the "what's next" guidance, so
# bootstrap should skip its standalone "Next: chezmoi init --apply / mise install"
# hint (we run it right below) to avoid contradictory instructions.
DOTFILES_BOOTSTRAP_CHAINED=1 "$here/installer/bootstrap.sh"

[ "$headless_persist" = 1 ] && persist_headless_to_mise

# Invoke the just-installed chezmoi by ABSOLUTE path so this still works when
# ~/.local/bin isn't on PATH yet (the whole point of doing it here). Not `exec`:
# we want to print the closing guidance afterwards. Preserve chezmoi's exit code.
"$bin_dir/chezmoi" init --apply --source="$here"
rc=$?

if [ "$rc" -eq 0 ]; then
  cat <<EOF

[*] セットアップ完了。
    dotfiles は新しいシェルで ~/.local/bin (mise, chezmoi) と ~/bin を PATH に
    通します。今のシェルにはまだ反映されていないので、ログインし直すか:

        exec "\$SHELL" -l

    を実行してから mise / chezmoi を使ってください。
EOF
fi
exit "$rc"
