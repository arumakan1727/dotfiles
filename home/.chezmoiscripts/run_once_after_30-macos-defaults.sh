#!/usr/bin/env bash
# run_once (chezmoi): macOS system defaults (Dock/Finder) and gpg-agent pinentry
# wiring. Delegates to the repo's installer scripts so the logic stays in one
# place (and lintable via `make lint`). No-op (early exit) on non-macOS.
#
# No chezmoi template here: chezmoi injects CHEZMOI_OS / CHEZMOI_SOURCE_DIR into
# the script environment, so the OS branch is a plain shell guard and repo_root
# is derived from the env (one level above CHEZMOI_SOURCE_DIR = home/).
#
# Note: because this wrapper's content does not change when the referenced
# installer scripts change, re-running after editing them needs a manual
# `installer/macos_defaults.sh` (or reset chezmoi's script state).
set -Eeuo pipefail

[ "${CHEZMOI_OS:-}" = "darwin" ] || exit 0

repo_root="$(cd "$(dirname "$CHEZMOI_SOURCE_DIR")" && pwd -P)"

"${repo_root}/installer/macos_defaults.sh"
"${repo_root}/installer/gpg-agent.sh"
