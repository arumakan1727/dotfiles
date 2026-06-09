#!/usr/bin/env bash
# Host-side orchestrator for the Linux reproducibility test.
#
#   ./test/run.sh [smoke|full|shell]
#
# Builds a clean Debian image, mounts the current working tree read-only at
# /src, and runs test/in-container.sh inside it. The container goes through the
# real fresh-machine flow: bootstrap -> chezmoi init --apply -> verify.
#
# `shell` skips the assertions and drops you into an interactive shell in the
# same clean image (manual triage of the fresh-machine flow).
#
# Tests the WORKING TREE (not the committed state): in-container.sh copies /src
# minus .git/tmp, so uncommitted changes are exercised too.
#
# A GitHub token is forwarded when available (env GITHUB_TOKEN/GH_TOKEN, else
# `gh auth token`) so the `full` test's mise installs don't hit the anonymous
# GitHub API rate limit. It's the user's own machine + token; smoke needs none.
set -Eeuo pipefail

LEVEL="${1:-smoke}"
case "$LEVEL" in
  smoke | full | shell) ;;
  *) echo "usage: $0 [smoke|full|shell]" >&2; exit 2 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd -P)"
readonly IMAGE="dotfiles-linux-test"

# Collect a GitHub token (best effort) to avoid API rate limits.
token="${GITHUB_TOKEN:-${GH_TOKEN:-}}"
if [ -z "$token" ] && command -v gh >/dev/null 2>&1; then
  token="$(gh auth token 2>/dev/null || true)"
fi
# bash 3.2 (stock macOS) + `set -u`-safe optional array.
docker_env=()
if [ -n "$token" ]; then
  docker_env+=(-e "GITHUB_TOKEN=$token" -e "GH_TOKEN=$token")
  echo "[test] forwarding a GitHub token to the container"
fi

echo "[test] building image '$IMAGE' (debian:bookworm-slim)…"
docker build -t "$IMAGE" -f "$SCRIPT_DIR/Dockerfile" "$SCRIPT_DIR"

if [ "$LEVEL" = shell ]; then
  echo "[test] launching an interactive shell in '$IMAGE'."
  echo "[test] the working tree is mounted read-only at /src. To exercise the"
  echo "       fresh-machine flow against a writable copy:"
  echo "         cp -a /src ~/dotfiles && cd ~/dotfiles && ./install.sh"
  echo "       (or: ./installer/bootstrap.sh then chezmoi init --apply --source=\$PWD)"
  exec docker run --rm -it \
    -v "$REPO_ROOT:/src:ro" \
    -e DOTFILES_HEADLESS=1 \
    ${docker_env[@]+"${docker_env[@]}"} \
    "$IMAGE" \
    bash -l
fi

echo "[test] running '$LEVEL' test in container…"
exec docker run --rm \
  -v "$REPO_ROOT:/src:ro" \
  -e "TEST_LEVEL=$LEVEL" \
  ${docker_env[@]+"${docker_env[@]}"} \
  "$IMAGE" \
  /src/test/in-container.sh "$LEVEL"
