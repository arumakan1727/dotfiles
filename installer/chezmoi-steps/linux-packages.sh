#!/usr/bin/env bash
# chezmoi-step (Linux only): install the few SYSTEM packages the dotfiles need
# but cannot provide through mise / Homebrew, mapping each capability to the
# running distro's package name. Invoked by
# home/.chezmoiscripts/run_onchange_after_05-system-packages.sh.tmpl.
#
# Capabilities ensured:
#   - libatomic  : the prebuilt `node` mise installs links against libatomic.so.1,
#                  which is absent on a minimal Amazon Linux 2023 (node then fails
#                  with "libatomic.so.1: cannot open shared object file" and every
#                  npm-backend tool is skipped).
#   - zsh        : the login shell the whole config targets; AL2023 minimal ships
#                  without it.
#   - cc (gcc)   : nvim-treesitter (main/rewrite) compiles parsers from C source
#                  with the `tree-sitter` CLI; no compiler => no syntax highlight.
#
# Cross-distro: package manager + names are resolved from /etc/os-release. macOS
# is handled by Homebrew (step 10) and is skipped here; an UNKNOWN distro is
# warned-about and skipped rather than failing the whole apply.
#
# No-privilege safe: only escalates when something is actually MISSING, and if it
# cannot escalate (no root and no usable sudo — e.g. a shared company host you
# only have SSH access to) it WARNS and exits 0. The dotfiles still apply; the
# missing pieces just need a manual install there. A fully-provisioned host needs
# no sudo at all because every capability check short-circuits.
#
# Idempotent: re-running with everything present is a no-op.
set -Eeuo pipefail
[ -n "${DOTFILES_DEBUG:-}" ] && set -x

[ "$(uname -s)" = Linux ] || { echo "[sys-pkgs] not Linux — skipping"; exit 0; }
# Mirrors DOTFILES_SKIP_BREW: let CI exercise apply without touching system pkgs.
[ -n "${DOTFILES_SKIP_SYSTEM_PKGS:-}" ] && { echo "[sys-pkgs] DOTFILES_SKIP_SYSTEM_PKGS set — skipping"; exit 0; }

# --- what is missing? (each check short-circuits the need for any privilege) ---
need_zsh=0;       command -v zsh >/dev/null 2>&1 || need_zsh=1
need_cc=0;        { command -v cc >/dev/null 2>&1 || command -v gcc >/dev/null 2>&1; } || need_cc=1
need_libatomic=0; ldconfig -p 2>/dev/null | grep -q 'libatomic\.so\.1' || need_libatomic=1

if [ "$need_zsh" = 0 ] && [ "$need_cc" = 0 ] && [ "$need_libatomic" = 0 ]; then
  echo "[sys-pkgs] zsh, a C compiler and libatomic all present — nothing to do"
  exit 0
fi

# --- resolve package manager + per-distro package names -----------------------
# shellcheck disable=SC1091  # /etc/os-release is data, not in the repo
. /etc/os-release 2>/dev/null || true
id_tokens=" ${ID:-} ${ID_LIKE:-} "

install_cmd=""; pm=""
pkg_libatomic=""; pkg_cc=""
case "$id_tokens" in
  *" amzn "*|*" fedora "*|*" rhel "*|*" centos "*|*" rocky "*|*" almalinux "*)
    if command -v dnf >/dev/null 2>&1; then pm=dnf; install_cmd="dnf install -y"
    elif command -v yum >/dev/null 2>&1; then pm=yum; install_cmd="yum install -y"; fi
    pkg_libatomic="libatomic"; pkg_cc="gcc" ;;
  *" debian "*|*" ubuntu "*)
    command -v apt-get >/dev/null 2>&1 && { pm=apt; install_cmd="apt-get install -y"; }
    pkg_libatomic="libatomic1"; pkg_cc="build-essential" ;;  # build-essential = gcc + libc headers + make
  *" arch "*|*" archarm "*|*" manjaro "*)
    command -v pacman >/dev/null 2>&1 && { pm=pacman; install_cmd="pacman -S --needed --noconfirm"; }
    pkg_libatomic="gcc-libs"; pkg_cc="gcc" ;;  # libatomic.so.1 ships in gcc-libs (base; usually already present)
esac

if [ -z "$pm" ]; then
  echo "[sys-pkgs] WARN: unrecognised distro (ID=${ID:-?} ID_LIKE=${ID_LIKE:-?}); install manually if needed:" >&2
  [ "$need_zsh" = 1 ]       && echo "  - zsh" >&2
  [ "$need_cc" = 1 ]        && echo "  - a C compiler (gcc / build-essential)" >&2
  [ "$need_libatomic" = 1 ] && echo "  - libatomic (provides libatomic.so.1)" >&2
  exit 0
fi

pkgs=()
[ "$need_zsh" = 1 ]       && pkgs+=("zsh")
[ "$need_cc" = 1 ]        && [ -n "$pkg_cc" ]        && pkgs+=("$pkg_cc")
[ "$need_libatomic" = 1 ] && [ -n "$pkg_libatomic" ] && pkgs+=("$pkg_libatomic")
[ ${#pkgs[@]} -eq 0 ] && { echo "[sys-pkgs] nothing to install"; exit 0; }

# --- pick an elevation method, or skip gracefully -----------------------------
sudo_cmd=""
if [ "$(id -u)" = 0 ]; then
  sudo_cmd=""
elif command -v sudo >/dev/null 2>&1 && sudo -n true 2>/dev/null; then
  sudo_cmd="sudo"                                   # passwordless sudo available
elif command -v sudo >/dev/null 2>&1 && [ -t 0 ]; then
  sudo_cmd="sudo"                                   # interactive TTY: one password prompt is fine
else
  echo "[sys-pkgs] WARN: need to install [${pkgs[*]}] but have no root and no usable sudo — skipping." >&2
  echo "[sys-pkgs] On a host where you lack privileges this is expected. To install manually:" >&2
  echo "[sys-pkgs]   sudo $install_cmd ${pkgs[*]}" >&2
  exit 0
fi

echo "[sys-pkgs] installing via $pm: ${pkgs[*]}"
[ "$pm" = apt ] && { $sudo_cmd apt-get update -y || true; }   # refresh index on a fresh box
# shellcheck disable=SC2086  # $install_cmd is an intentional multi-word command
$sudo_cmd $install_cmd "${pkgs[@]}"
echo "[sys-pkgs] done"
