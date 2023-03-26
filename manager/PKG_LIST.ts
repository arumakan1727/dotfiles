import { InstallWay } from "./INSTALL_CMD.ts";

export const cli: {
  essentials: readonly InstallWay[];
  extras: readonly InstallWay[];
  devs: readonly InstallWay[];
} = {
  essentials: [
    { apt: "silver-searcher-ag", brew: "ag" },
    "ag",
    "rg",
    "bat",
    "wget",
    "delta",
    "fzf",
    "ghq",
    "xh",
    "htop",
    "jq",
    "coreutils",
    "moreutils",
    "netcat",
    "nvim",
    "openssl",
    "qalc",
    "starship",
    "tmux",
    "trans",
    "lsd",
    "zip",
    "unzip",
  ],
  extras: [
    "broot",
    "sl",
    "lolcat",
    "dust",
    "monolith",
    "navi",
    "tealdeer",
    "pastel",
    "ranger",
    "ffmpeg",
    "imagemagick",
  ],
  devs: [
    "gh",
    "docker",
    "docker-compose",
    "gibo",
    "rustup",
    "pyenv",
    "rbenv",
    "volta",
    "deno",
    "stack",
    "go",
    "dotnet",
    "sdkman",
    "yarn",
    "julia",
    "g++",
    "clangd",
  ],
} as const;

export const fonts: readonly InstallWay[] = [] as const;

export const gui: readonly InstallWay[] = [];
