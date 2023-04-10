# dotfiles

秘伝のタレ。
たまごっちのように愛情込めて育てていけ。

## Install

```shell
git clone git@github.com:arumakan1727/dotfiles.git
cd dotfiles
make dotfiles/apply/symlink

## or you can use 'copy' strategy
# make dotfiles/apply/copy
```

Backups will be created in `~/.cache/armkn-dotfiles/backup/`.

You can use 'copy' strategy instead of 'symlink'.

## Help

Run `make help` or just `make`.

```console
$ make
lint/Makefile          Lint makefiles
dotfiles/apply/symlink Apply dotfiles using symlink, and remove deadlinks
dotfiles/apply/copy    Apply dotfiles using copy, and remove deadlinks
dotfiles/list-symlinks List applied symlinks
cli/install/essentials Install essential CLI
cli/install/extras     Install additional CLI
cli/install/devs       Install development tools CLI
gui/install            Install GUI applications
help                   Show Makefile tasks
```
