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

class ErrCannotGetInode extends Error {
  constructor(path: string) {
    super(`cannot get inode of ${path}`);
    this.name = "ErrCannotGetInode";
  }
}

export function isSameInodeSameDevice(path1: string, path2: string): boolean {
  try {
    const s1 = Deno.statSync(path1);
    if (s1.ino == null) throw new ErrCannotGetInode(path1);

    const s2 = Deno.statSync(path2);
    if (s2.ino == null) throw new ErrCannotGetInode(path2);

    return s1.dev === s2.dev && s1.ino === s2.ino;
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
  if (filepath === prefix) {
    return into;
  }
  if (filepath.startsWith(prefix + "/")) {
    return path.join(into, filepath.substring(prefix.length + 1));
  }
  return filepath;
}
