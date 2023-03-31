import { InstallWay } from "./INSTALL_CMD.ts";

export const cli: {
  essentials: readonly InstallWay[];
  extras: readonly InstallWay[];
  devs: readonly InstallWay[];
} = {
  essentials: [
    // GNU/Linux commands (needed by other install script)
    { id: "coreutils" },
    { id: "diffutils" },
    { id: "findutils" },
    { id: "gawk" },
    { id: "gpg" },
    { id: "grep" },
    { id: "gzip" },
    { id: "moreutils" },
    { id: "sed", brew: "gnu-sed" },
    { id: "tar", brew: "gnu-tar" },

    // other essentials (needed by other install script)
    { id: "go", cmd: ["./installer/go.sh"] },
    { id: "jq" },

    // terminal apps
    { id: "neovim", cmd: ["./installer/neovim-nightly.sh"] },
    { id: "tmux" },

    // modern alternatives of gnu linux command
    { id: "bat" },
    { id: "git-delta", cmd: ["./installer/git-delta.sh"] },
    { id: "htop" },
    { id: "lsd", cmd: ["./installer/lsd.sh"] },
    { id: "xh", cmd: ["./installer/xh.sh"] },
    { id: "zoxide", shUrl: "ajeetdsouza/zoxide/main/install.sh", github: true },

    // utils
    { id: "ag", apt: "silver-searcher-ag" },
    { id: "direnv" },
    { id: "fzf" },
    { id: "rg", apt: "ripgrep" },
  ],
  extras: [
    { id: "broot" },
    { id: "dust" },
    { id: "ffmpeg" },
    { id: "imagemagick" },
    { id: "starship", shUrl: "https://starship.rs/install.sh" },
    { id: "tealdeer" },
    { id: "translate-shell" },
  ],
  devs: [
    // version-multiplexer
    { id: "pyenv", shUrl: "https://pyenv.run", sh: "bash" },
    { id: "rbenv" },
    { id: "rustup", shUrl: "https://sh.rustup.rs" },
    { id: "sdkman", shUrl: "https://get.sdkman.io", sh: "bash" },
    { id: "volta", shUrl: "https://get.volta.sh", sh: "bash" },

    // misc
    { id: "docker", cmd: ["./installer/docker.sh"] },
    { id: "ghq", cmd: ["go", "install", "github.com/x-motemen/ghq@latest"] },
    { id: "gibo", cmd: ["./installer/gibo.sh"] },
    { id: "pnpm", shUrl: "https://get.pnpm.io/install.sh" },
  ],
} as const;

export const fonts: readonly InstallWay[] = [] as const;

export const gui: readonly InstallWay[] = [] as const;
