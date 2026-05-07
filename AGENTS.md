# AGENTS.md

Agent-only notes. Not for human reading. Terse, dense, English. Update in place when behavior here drifts from reality. `CLAUDE.md` is a symlink to this file.

## Repo

Personal dotfiles for macOS (primary) and Linux (i3wm). Layout under `homedir/` mirrors `$HOME`. Top-level: `Brewfile{,.lock.json}`, `Makefile`, `cspell.config.yml`, `installer/`, `etc/`, `migration/`, `tmp/`.

## Symlink topology

- `installer/symlink_dotfiles.sh` (`make i/symlink`) symlinks **immediate children** of `homedir/` into `$HOME`. Glob is `.*` at top level only — not recursive.
- Therefore `~/.config` is a single symlink to `dotfiles/homedir/.config/`. Subpaths like `~/.config/pip/pip.conf` resolve through the parent symlink; there is **no per-file symlink**.
- Implication: any file under `homedir/.config/**` physically lives in this repo. "Stop tracking" = `git rm --cached` + `.gitignore`. You cannot relocate it without breaking the symlink chain or moving config to an alternate XDG path.
- `bin/` is symlinked per-file. `Library/Application Support/AquaSKK` is symlinked by name.

## Commits

- Subject style: lowercase scope + colon, e.g. `zsh: ...`, `mise: ...`, `cursor: ...`, `karabiner: ...`, `chore: ...`. Imperative, no period. Body optional, hard-wrap ~72.

## Line endings

- Repo has no `.gitattributes`. `core.autocrlf=input` + `core.safecrlf=true`.
- `.gitignore` is stored as LF in the index. The Edit tool may produce mixed/CRLF in the working tree, which makes `git add` fail with "CRLF would be replaced by LF". Fix: `perl -i -pe 's/\r\n/\n/g' .gitignore` before staging. Same trap applies to any text file checked in as LF.

## Sensitive files / known gotchas

- `homedir/.config/pip/pip.conf` — gitignored. Holds Flatt Security `pypi.flatt.tech` index-url with embedded token. Never re-track. Physical file lives in repo dir.
- `homedir/.config/mise/npmrc` — **not** a mise-official config file. Tracked. Loaded only via the `mise()` wrapper in `.zshrc` as `NPM_CONFIG_USERCONFIG` for `mise use|install npm:*`. Exists to bypass `~/.npmrc` `min-release-age` vs `MISE_INSTALL_BEFORE` conflict on npm 11. Registry points at Flatt Security Takumi Guard (external SaaS — OK to publish).
- `homedir/.config/karabiner/karabiner.json` — Karabiner-Elements rewrites the file on save with its own indentation, producing massive whitespace-only diffs. Always inspect with `git diff -w` to find the substantive change, and call this out in commit messages.

## Shell init order (zsh)

`.zshenv` → `.zprofile` (login) → `.zshrc` (interactive). Notable:

- `.zshenv`: env vars only. `MANPAGER`/`EDITOR` use `${VAR:-default}` to respect parent-injected values (Claude Code `settings.json` `env.MANPAGER='col -bx'` relies on this).
- `.zprofile`: OrbStack init.
- `.zshrc`: PATH/fpath/manpath/infopath setup lives here, **after** macOS `/etc/zprofile`'s `path_helper` runs. mise/zoxide/workmux activations are inlined with file-based caching under `$XDG_CACHE_HOME/zsh/` and deferred via `zsh-defer`. Synchronous `compinit -C` (don't re-run in lazy fragments). `mise()` wrapper intercepts `use|install|i|upgrade|up` containing `npm:` to inject `NPM_CONFIG_USERCONFIG`.
- `.bashrc` mirrors zsh equivalents where relevant. Also conditional `MANPAGER`.

## Mise

- `homedir/.config/mise/config.toml` — global tool list. Prefer registry shortnames (`rg`, `fd`, `gh`, ...). Fall back to `aqua:owner/repo` only when no shortname exists; annotate with reason in comment.
- `MISE_INSTALL_BEFORE=7d` and `UV_EXCLUDE_NEWER=P7D` in `.zshrc` enforce release-age policy. Don't strip them.
- `aws-cli` is intentionally Homebrew-installed, not via mise (PKG version is slow to start). Comment in config.toml explains.

## Installer / tasks

- `make i/symlink` — link / re-link dotfiles (idempotent).
- `make i/symlink/dryrun` — preview.
- `make i/cli`, `make i/fonts` — install bundles.
- `make brew/dump`, `make brew/install`, `make upgrade/brew` — Homebrew bundle workflow.
- `make find/dead-symlink[/del]` — cleanup orphan symlinks.
- `make lint` — shellcheck for `installer/*`.

