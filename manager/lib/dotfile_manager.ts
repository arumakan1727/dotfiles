import {
  BACKUP_DATE_FORMAT,
  BACKUP_ROOT,
  CONTENT_ROOT,
  SYMLINK_STATE_FILE,
} from "../CONFIG.ts";
import { colors, datetime, fs, path } from "../deps.ts";
import * as fs_util from "../util/fs.ts";
import * as textfile from "../util/textfile.ts";
import { fetchGitRootAbsPath, fetchGitTrackedFileList } from "../lib/repository.ts";

type SymlinkPath = string;
type Path = string;

export function loadSymlinkState(filepath: string): SymlinkPath[] {
  return textfile.readJSON(filepath, { fallback: [] });
}

export function saveSymlinkState(filepath: string, symlinks: readonly SymlinkPath[]) {
  textfile.writeJSONWithMkdir(filepath, symlinks);
}

export type RemoveDeadSymlinksOption = {
  dryRun?: boolean;
  onStart?: () => void;
  beforeDeadlinkRemove?: (filepath: string) => void;
  afterDeadlinkRemove?: (filepath: string) => void;
  onFinish?: (deadLinkCount: number) => void;
};

export function removeDeadSymlinks(
  symlinks: readonly SymlinkPath[],
  opt?: RemoveDeadSymlinksOption,
): SymlinkPath[] {
  opt?.onStart?.();

  const cleanedPaths: SymlinkPath[] = [];
  const dryRun = opt?.dryRun;
  let deadLinkCount = 0;

  symlinks.forEach((linkName) => {
    if (fs_util.isFileOrDir(linkName, { followSymlink: true })) {
      cleanedPaths.push(linkName);
      return;
    }
    if (fs_util.isSymlink(linkName)) {
      ++deadLinkCount;
      opt?.beforeDeadlinkRemove?.(linkName);
      if (!dryRun) Deno.removeSync(linkName);
      opt?.afterDeadlinkRemove?.(linkName);
    }
  });

  opt?.onFinish?.(deadLinkCount);
  return cleanedPaths;
}

export function removeDeadSymlinksVerbose(
  symlinks: readonly SymlinkPath[],
  opt?: RemoveDeadSymlinksOption,
): SymlinkPath[] {
  return removeDeadSymlinks(symlinks, {
    ...opt,
    onStart: () => {
      console.log(colors.brightYellow.bold("Checking dead symlinks..."));
      opt?.onStart?.();
    },
    beforeDeadlinkRemove: (filepath) => {
      console.log(
        colors.cyan("[INFO] remove dead symlink:"),
        colors.yellow(fs_util.abbrHomePathToTilde(filepath)),
      );
      opt?.beforeDeadlinkRemove?.(filepath);
    },
    onFinish: (deadLinkCount) => {
      console.log(
        deadLinkCount === 0
          ? colors.green.bold("[OK] No dead symlinks found.")
          : colors.green.bold(`[OK] Removed ${deadLinkCount} dead symlinks.`),
      );
      opt?.onFinish?.(deadLinkCount);
    },
  });
}

// "homedir/.config/xxx/yyy/zzz" -> "homedir/.config/xxx"
function calcOptimizedSymlinkTargets(dotfiles: readonly Path[]): Path[] {
  const configDir = path.join(CONTENT_ROOT, ".config/");
  const set = new Set<Path>();
  for (const s of dotfiles) {
    if (s.startsWith(configDir)) {
      const head = s.substring(configDir.length).split(path.SEP)[0];
      set.add(path.join(configDir, head));
    } else {
      set.add(s);
    }
  }
  return Array.from(set);
}

export type DotfileApplyStrategy = "symlink" | "copy";

export type ApplyRepoDotfilesOption = {
  strategy: DotfileApplyStrategy;
  backupDir?: string;
  dryRun?: boolean;
  onStart?: (gitRootAbsPath: Path) => void;
  beforeApply?: (repoFile: Path, dest: Path) => void;
  afterApplySuccess?: (repoFile: Path, dest: Path) => void;
  beforeBackup?: (orig: Path, backup: Path) => void;
  afterBackupSuccess?: (orig: Path, backup: Path) => void;
  onFinish?: (appliedCount: number) => void;
};

export async function applyRepoDotfiles(opt: ApplyRepoDotfilesOption) {
  const { strategy, backupDir, dryRun } = opt;
  const HOME = Deno.env.get("HOME")!;
  const gitRootAbsPath = await fetchGitRootAbsPath();
  opt.onStart?.(gitRootAbsPath);

  const dotfiles = await fetchGitTrackedFileList(CONTENT_ROOT);
  const symlinkTargets = calcOptimizedSymlinkTargets(dotfiles);

  const usingSymlink = strategy === "symlink";
  const applyFn: (repoFile: Path, dest: Path) => void = usingSymlink
    ? Deno.symlinkSync
    : fs.copy;
  let appliedCount = 0;

  symlinkTargets.forEach((dotfile) => {
    const repoFile = path.join(gitRootAbsPath, dotfile);
    const dest = dotfile.replace(CONTENT_ROOT, HOME);

    // シンボリックリンク先が既にリポジトリ内の dotfile を指しているならスキップ
    if (usingSymlink && fs_util.isSameInodeSameDevice(dest, repoFile)) return;
    opt.beforeApply?.(repoFile, dest);

    // dest が存在し、それがシンボリックリンクでないならバックアップへ移動
    if (fs_util.isFileOrDir(dest, { followSymlink: false })) {
      const backupPath = dotfile.replace(
        CONTENT_ROOT,
        backupDir ??
          path.join(BACKUP_ROOT, datetime.format(new Date(), BACKUP_DATE_FORMAT)),
      );
      opt.beforeBackup?.(dest, backupPath);
      if (!dryRun) {
        fs_util.mkdirRecursive(path.dirname(backupPath));
        Deno.renameSync(dest, backupPath);
      }
      opt.afterBackupSuccess?.(dest, backupPath);
    }

    // copy または symlink を適用
    if (!dryRun) {
      fs_util.ensureRemoved(dest);
      fs_util.mkdirRecursive(path.dirname(dest));
      applyFn(repoFile, dest);
    }
    ++appliedCount;
    opt.afterApplySuccess?.(repoFile, dest);
  });

  opt.onFinish?.(appliedCount);
}

export async function applyRepoDotfilesVerbose(opt: ApplyRepoDotfilesOption) {
  const { dryRun, strategy } = opt;
  let gitRootAbsPath: Path;

  await applyRepoDotfiles({
    ...opt,
    onStart: (s) => {
      gitRootAbsPath = s;
      opt.onStart?.(s);
    },
    beforeApply: (repoFile, dest) => {
      console.log(
        dryRun ? " (dry-run)" : "",
        colors.magenta(fs_util.replacePathPrefix(repoFile, gitRootAbsPath, "dotfiles")),
        "->",
        colors.green(fs_util.abbrHomePathToTilde(dest)),
      );
      opt.beforeApply?.(repoFile, dest);
    },
    beforeBackup: (orig, backup) => {
      console.log(
        colors.dim.white(`  ... backup to ${fs_util.abbrHomePathToTilde(backup)}`),
      );
      opt.beforeBackup?.(orig, backup);
    },
    onFinish: (appliedCount) => {
      console.log(
        colors.green.bold(`[OK] Applied ${appliedCount} dotfiles using ${strategy}`),
      );
      opt.onFinish?.(appliedCount);
    },
  });
}

export async function runApply(opt: {
  strategy: DotfileApplyStrategy;
  dryRun?: boolean;
}) {
  const { strategy, dryRun } = opt;
  const symlinksBeforeApply: ReadonlyArray<Path> = loadSymlinkState(SYMLINK_STATE_FILE);
  const symlinkSet = new Set<Path>(symlinksBeforeApply);

  try {
    removeDeadSymlinksVerbose(symlinksBeforeApply, {
      dryRun,
      afterDeadlinkRemove: (path) => symlinkSet.delete(path),
    });

    console.log(); // new line

    const afterApplySuccess = (strategy === "symlink")
      ? (_repoFile: Path, dest: Path) => symlinkSet.add(dest)
      : (_repoFile: Path, dest: Path) => symlinkSet.delete(dest);

    await applyRepoDotfilesVerbose({ strategy, dryRun, afterApplySuccess });
  } finally {
    if (!dryRun) {
      const symlinkList = Array.from(symlinkSet).sort();
      saveSymlinkState(SYMLINK_STATE_FILE, symlinkList);
    }
  }
}
