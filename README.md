# dotfiles
Target environments: Linux (i3wm), macOS

秘伝のタレ。
たまごっちのように愛情込めて育てていけ。

## Install

1. Create symbolic links to the dotfiles.

    ```shell
    make i/symlink
    ```

    You can see what will happen when creating symlinks.

    ```shell
    make i/symlink/dryrun
    ```

2. Install my favorite CLI apps, fonts, macOS configurations.

    ```shell
    make i/cli

    make i/fonts

    # on macOS
    make i/macos
    ```

## How to update symlinks
Run the following command.
This command is idempotent, ensuring safety for repeated execution.

```console
$ make i/symlink
./installer/symlink_dotfiles.sh
[SKIP] already correctly symlinked: homedir/.config  ->  ~/.config
[SKIP] already correctly symlinked: homedir/.pam_environment  ->  ~/.pam_environment
[SKIP] already correctly symlinked: homedir/.tmux.conf  ->  ~/.tmux.conf
[SKIP] already correctly symlinked: homedir/.dircolors  ->  ~/.dircolors
[SKIP] already correctly symlinked: homedir/.bashrc  ->  ~/.bashrc
[SKIP] already correctly symlinked: homedir/.zshrc  ->  ~/.zshrc

...
```

## Other scripts

Run `make help` or just `make`.

```sh
make help
```
