import { CONTENT_ROOT, SYMLINK_STATE_FILE } from "../CONFIG.ts";
import { Command, path } from "../deps.ts";
import { fileOrDirExists, symlinkExists } from "../libs/fs.ts";
import { fetchGitRootAbsPath, fetchGitTrackedFileList } from "../libs/git.ts";

const cmdSync = new Command()
  .description("sync dotfiles with auto clean")
  .action(runSync);

type SymlinkPath = string;
type Path = string;

function loadSymlinkState(filepath: string): SymlinkPath[] {
  let content = "";
  try {
    content = Deno.readTextFileSync(filepath);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return [];
    }
  }
  return JSON.parse(content || "[]");
}

function saveSymlinkState(filepath: string, paths: readonly SymlinkPath[]) {
  Deno.mkdirSync(path.dirname(filepath), { recursive: true });
  Deno.writeTextFileSync(filepath, JSON.stringify(paths));
}

function removeDeadSymlink(symlinks: readonly SymlinkPath[]): SymlinkPath[] {
  const cleanedPaths: SymlinkPath[] = [];

  symlinks.forEach((filepath) => {
    if (fileOrDirExists(filepath)) {
      cleanedPaths.push(filepath);
      return;
    }
    if (symlinkExists(filepath)) {
      Deno.removeSync(filepath);
    }
  });
  return cleanedPaths;
}

async function applyRepoDotfiles(option: {
  strategy: "symlink" | "copy";
  onSuccess: (origin: Path, dest: Path) => void;
}) {
  const { strategy, onSuccess } = option;
  const HOME = Deno.env.get("HOME")!;
  const gitRootAbsPath = await fetchGitRootAbsPath();
  const dotfiles = await fetchGitTrackedFileList(CONTENT_ROOT, {
    resultPathStyle: "rel",
  });

  const apply = strategy === "copy" ? Deno.copyFileSync : Deno.symlinkSync;

  for (const dotfile of dotfiles) {
    const origin = path.join(gitRootAbsPath, dotfile);
    const dest = dotfile.replace(CONTENT_ROOT, HOME);
    Deno.mkdirSync(path.dirname(dest), { recursive: true });
    apply(origin, dest);
    onSuccess(origin, dest);
  }
}

async function runSync() {
  let symlinks = loadSymlinkState(SYMLINK_STATE_FILE);
  try {
    symlinks = removeDeadSymlink(symlinks);
    const symlinkSet = new Set(symlinks);
    await applyRepoDotfiles({
      strategy: "symlink",
      onSuccess: (_entityPath, linkPath) => symlinkSet.add(linkPath),
    });
    symlinks = Array.from(symlinkSet).sort();
  } finally {
    saveSymlinkState(SYMLINK_STATE_FILE, symlinks);
  }
}
