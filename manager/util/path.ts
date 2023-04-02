import { path } from "../deps.ts";

const HOME = Deno.env.get("HOME")!;

export function expandTildePath(filepath: string): string {
  return replacePathPrefix(filepath, "~", HOME);
}

export function abbrHomePathToTilde(filepath: string): string {
  return replacePathPrefix(filepath, HOME, "~");
}

export function replacePathPrefix(filepath: string, prefix: string, into: string) {
  if (filepath === prefix) {
    return into;
  }
  if (filepath.startsWith(prefix + "/")) {
    return path.join(into, filepath.substring(prefix.length + 1));
  }
  return filepath;
}
