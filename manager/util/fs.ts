export function isFileOrDir(
  filepath: string,
  opt: { followSymlink: boolean },
): boolean {
  const stat = opt.followSymlink ? Deno.statSync : Deno.lstatSync;
  try {
    const s = stat(filepath);
    return !s.isSymlink && (s.isFile || s.isDirectory);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return false;
    }
    throw e;
  }
}

export function isSymlink(filepath: string): boolean {
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

export function ensureRemoved(filepath: string) {
  try {
    Deno.removeSync(filepath);
  } catch (e) {
    if (e! instanceof Deno.errors.NotFound) {
      throw e;
    }
  }
}

export function mkdirRecursive(path: string) {
  Deno.mkdirSync(path, { recursive: true });
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
