import { InstallWay } from "./INSTALL_CMD.ts";
import { path } from "./deps.ts";

const HOME = Deno.env.get("HOME")!;

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
    { id: "unzip" },

    // other essentials (needed by other install script)
    { id: "go", cmd: ["./installer/go.sh"] },
    { id: "jq" },
    { id: "pipx" },

    // terminal apps
    { id: "neovim", cmd: ["./installer/neovim-nightly.sh"] },
    { id: "tmux" },

    // modern alternatives of gnu linux command
    { id: "bat" },
    { id: "fd", apt: "fd-find" },
    { id: "git-delta", cmd: ["./installer/git-delta.sh"] },
    { id: "htop" },
    { id: "lsd", cmd: ["./installer/lsd.sh"] },
    { id: "xh", cmd: ["./installer/xh.sh"] },
    { id: "zoxide", shUrl: "ajeetdsouza/zoxide/main/install.sh", github: true },

    // utils
    { id: "ag", apt: "silver-searcher-ag" },
    { id: "ascii" },
    { id: "direnv" },
    { id: "fzf" },
    { id: "netcat" },
    { id: "nkf" },
    { id: "nmap" },
    { id: "rg", apt: "ripgrep" },
    { id: "tree" },
  ],
  extras: [
    { id: "broot" },
    { id: "dust" },
    { id: "exiftool" },
    { id: "ffmpeg" },
    { id: "imagemagick" },
    { id: "libqalculate" }, // `qalc` command
    { id: "neofetch" },
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

    // setup corepack
    { id: "corepack", cmd: ["volta", "install", "corepack"] },
    {
      id: "#corepack-enable",
      cmd: [
        "corepack",
        "enable",
        "--install-directory",
        path.join(HOME, ".volta", "bin"),
        "npm",
        "yarn",
        "pnpm",
      ],
    },

    // compiler / runtime / repl
    { id: "lua" },
    { id: "ipython", cmd: ["pipx", "install", "ipython"] },

    // lib
    { id: "libyaml" },

    // linter
    { id: "shellcheck" },
    { id: "markdownlint-cli" },
    { id: "cppcheck" },
    {
      id: "golangci-lint",
      cmd: [
        "go",
        "install",
        "github.com/golangci/golangci-lint/cmd/golangci-lint@latest",
      ],
    },

    // formatter
    { id: "stylua" },

    // misc
    { id: "docker", cmd: ["./installer/docker.sh"] },
    { id: "ghq", cmd: ["go", "install", "github.com/x-motemen/ghq@latest"] },
    { id: "gibo", cmd: ["./installer/gibo.sh"] },
  ],
} as const;

export const gui: readonly InstallWay[] = [] as const;
