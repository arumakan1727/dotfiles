import {
  BACKUP_DATE_FORMAT,
  BACKUP_ROOT,
  CONTENT_ROOT,
  SYMLINK_STATE_FILE,
} from "../CONFIG.ts";
import { colors, Command, datetime, path } from "../deps.ts";
import {
  abbrHomePathToTilde,
  isFileOrDir,
  isSameInodeSameDevice,
  isSymlink,
  replacePathPrefix,
} from "../libs/fs.ts";
import { fetchGitRootAbsPath, fetchGitTrackedFileList } from "../libs/git.ts";

const subcmdSync = new Command()
  .description("sync dotfiles with auto clean")
  .option("--dry-run", "Dry run")
  .action(runSync);

const rootCommand = new Command()
  .name("symlink.ts")
  .description("Sync, auto remove, restore dotfiles")
  .globalEnv("NO_COLOR=<value:any>", "Disable colored output")
  .action(() => {
    rootCommand.showHelp();
  })
  .command("sync", subcmdSync);

function main(args: string[]) {
  rootCommand.parse(args);
}

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

function removeDeadSymlink(
  symlinks: readonly SymlinkPath[],
  opt?: { dryRun?: boolean },
): SymlinkPath[] {
  const cleanedPaths: SymlinkPath[] = [];
  const dryRun = opt?.dryRun;
  let deadLinkCount = 0;

  console.log(colors.brightYellow.bold("Checking dead symlinks..."));

  symlinks.forEach((filepath) => {
    if (isFileOrDir(filepath, { followSymlink: true })) {
      cleanedPaths.push(filepath);
      return;
    }
    if (isSymlink(filepath)) {
      ++deadLinkCount;
      console.log(
        colors.cyan("[INFO] remove dead symlink:"),
        colors.yellow(abbrHomePathToTilde(filepath)),
      );
      if (!dryRun) Deno.removeSync(filepath);
    }
  });

  if (deadLinkCount === 0) {
    console.log(colors.green.bold("[OK] No dead symlinks found."));
  } else {
    console.log(colors.green.bold(`[OK] Removed ${deadLinkCount} dead symlinks.`));
  }
  return cleanedPaths;
}

async function applyRepoDotfiles(option: {
  strategy: "symlink" | "copy";
  onSuccess: (origin: Path, dest: Path) => void;
  backupDir: string;
  dryRun?: boolean;
}) {
  const { strategy, onSuccess, backupDir, dryRun } = option;
  const HOME = Deno.env.get("HOME")!;
  const gitRootAbsPath = await fetchGitRootAbsPath();
  const dotfiles = await fetchGitTrackedFileList(CONTENT_ROOT, {
    resultPathStyle: "rel",
  });

  const apply = strategy === "copy" ? Deno.copyFileSync : Deno.symlinkSync;
  const usingSymlink = strategy === "symlink";
  let appliedCount = 0;

  dotfiles.forEach((dotfile) => {
    const origin = path.join(gitRootAbsPath, dotfile);
    const dest = dotfile.replace(CONTENT_ROOT, HOME);

    const opNeed = !usingSymlink ||
      (usingSymlink && !isSameInodeSameDevice(origin, dest));
    if (!opNeed) return;

    console.log(
      dryRun ? " (dry-run)" : "",
      colors.magenta(replacePathPrefix(origin, gitRootAbsPath, "dotfiles")),
      "->",
      colors.green(abbrHomePathToTilde(dest)),
    );

    const backupNeed = !usingSymlink ||
      usingSymlink && isFileOrDir(dest, { followSymlink: false });
    if (backupNeed) {
      const backupPath = dotfile.replace(CONTENT_ROOT, backupDir);
      console.log(
        colors.dim.white(`  ... copy backup to ${abbrHomePathToTilde(backupPath)}`),
      );
      if (!dryRun) {
        Deno.mkdirSync(path.dirname(backupPath), { recursive: true });
        Deno.copyFileSync(dest, backupPath);
        if (usingSymlink) Deno.removeSync(dest);
      }
    }
    if (!dryRun) {
      Deno.mkdirSync(path.dirname(dest), { recursive: true });
      apply(origin, dest);
    }
    ++appliedCount;
    onSuccess(origin, dest);
  });

  console.log(colors.green.bold(`[OK] Applied ${appliedCount} dotfiles.`));
}

async function runSync(opt: { dryRun?: boolean }) {
  let symlinks = loadSymlinkState(SYMLINK_STATE_FILE);
  try {
    symlinks = removeDeadSymlink(symlinks);
    const symlinkSet = new Set(symlinks);
    const backupDir = path.join(
      BACKUP_ROOT,
      datetime.format(new Date(), BACKUP_DATE_FORMAT),
    );

    console.log(); // new line

    await applyRepoDotfiles({
      strategy: "symlink",
      onSuccess: (_entityPath, linkPath) => symlinkSet.add(linkPath),
      backupDir,
      dryRun: opt.dryRun,
    });
    symlinks = Array.from(symlinkSet).sort();
  } finally {
    if (!opt.dryRun) {
      saveSymlinkState(SYMLINK_STATE_FILE, symlinks);
    }
  }
}

if (import.meta.main) {
  main(Deno.args);
}
