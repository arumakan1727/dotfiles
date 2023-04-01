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
