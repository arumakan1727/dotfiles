import { path } from "../deps.ts";

export function fileExists(filepath: string): boolean {
  try {
    const s = Deno.statSync(filepath);
    return s.isFile;
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return false;
    }
    throw e;
  }
}

export function fileOrDirExists(filepath: string): boolean {
  try {
    const s = Deno.statSync(filepath);
    return s.isFile || s.isDirectory;
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return false;
    }
    throw e;
  }
}

export function symlinkExists(filepath: string): boolean {
  try {
    const s = Deno.lstatSync(filepath);
    return s.isSymlink;
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return false;
    }
    throw e;
  }
}

const HOME = Deno.env.get("HOME")!;

export function expandTildePath(filepath: string): string {
  return replacePathPrefix(filepath, "~", HOME);
}

export function abbrHomePathToTilde(filepath: string): string {
  return replacePathPrefix(filepath, HOME, "~");
}

export function replacePathPrefix(filepath: string, prefix: string, into: string) {
  filepath = path.normalize(filepath);
  if (filepath === prefix) {
    return into;
  }
  if (filepath.startsWith(prefix + "/")) {
    return path.join(into, filepath.substring(prefix.length + 1));
  }
  return filepath;
}
