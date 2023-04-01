import { path } from "./deps.ts";

const env = Deno.env.get;
const appName = "armkn-dotfiles";

export const DOTFILES_CACHE_HOME = path.join(
  env("XDG_CACHE_HOME") ?? path.join(env("HOME")!, ".cache"),
  appName,
);

export const DOTFILES_STATE_HOME = path.join(
  env("XDG_STATE_HOME") ?? path.join(env("HOME")!, ".local", "state"),
  appName,
);

export const SYMLINK_STATE_FILE = path.join(
  DOTFILES_STATE_HOME,
  "symlink-state.json",
);

export const CONTENT_ROOT = "homedir";
