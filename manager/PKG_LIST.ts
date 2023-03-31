import { InstallWay } from "./INSTALL_CMD.ts";

export const cli: {
  essentials: readonly InstallWay[];
  extras: readonly InstallWay[];
  devs: readonly InstallWay[];
} = {
  essentials: [
    // core (needed by other install script)
    { id: "GNU/Linux-commands", cmd: ["./installer/brew-GNU-Linux-commands.sh"] },
    { id: "go", cmd: ["./installer/go.sh"] },
    { id: "jq" },

    // terminal apps
    { id: "neovim", cmd: ["./installer/neovim-nightly.sh"] },
    { id: "starship", shUrl: "https://starship.rs/install.sh" },
    { id: "tmux" },

    // modern alternatives gnu linux command
    { id: "bat" },
    { id: "git-delta", cmd: ["./installer/git-delta.sh"] },
    { id: "htop" },
    { id: "lsd", cmd: ["./installer/lsd.sh"] },
    { id: "xh", cmd: ["./installer/xh.sh"] },
    { id: "zoxide", shUrl: "ajeetdsouza/zoxide/main/install.sh", github: true },

    // utils
    { id: "ag", apt: "silver-searcher-ag" },
    { id: "fzf" },
    { id: "ghq", cmd: ["go", "install", "github.com/x-motemen/ghq@latest"] },
    { id: "rg", apt: "ripgrep" },
  ],
  extras: [
    { id: "broot" },
    { id: "dust" },
    { id: "ffmpeg" },
    { id: "imagemagick" },
    { id: "pastel" },
    { id: "tealdeer" },
    { id: "translate-shell" },
  ],
  devs: [
    { id: "asdf" }, // TODO:
    { id: "docker", cmd: ["./installer/docker.sh"] },
    { id: "gh" },
    { id: "gibo" },
    { id: "julia" },
    { id: "pyenv" },
    { id: "rbenv" },
    { id: "rustup" },
    { id: "sdkman" },
    { id: "stack" },
    { id: "volta" },
    { id: "yarn" },
  ],
} as const;

export const fonts: readonly InstallWay[] = [] as const;

export const gui: readonly InstallWay[] = [] as const;
