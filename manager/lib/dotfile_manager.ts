import {
  BACKUP_DATE_FORMAT,
  BACKUP_ROOT,
  CONTENT_ROOT,
  SYMLINK_STATE_FILE,
} from "../CONFIG.ts";
import { colors, datetime, path } from "../deps.ts";
import * as fs from "../util/fs.ts";
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

type RemoveDeadSymlinksOption = {
  dryRun?: boolean;
};

type RemoveDeadSymlinksOptionWithHook = RemoveDeadSymlinksOption & {
  onStart?: () => void;
  onDeadlinkFound?: (filepath: string) => void;
  onFinish?: (deadLinkCount: number) => void;
};

export function removeDeadSymlinks(
  symlinks: readonly SymlinkPath[],
  opt?: RemoveDeadSymlinksOptionWithHook,
): SymlinkPath[] {
  opt?.onStart?.();

  const cleanedPaths: SymlinkPath[] = [];
  const dryRun = opt?.dryRun;
  let deadLinkCount = 0;

  symlinks.forEach((linkName) => {
    if (fs.isFileOrDir(linkName, { followSymlink: true })) {
      cleanedPaths.push(linkName);
      return;
    }
    if (fs.isSymlink(linkName)) {
      ++deadLinkCount;
      opt?.onDeadlinkFound?.(linkName);
      if (!dryRun) Deno.removeSync(linkName);
    }
  });

  opt?.onFinish?.(deadLinkCount);
  return cleanedPaths;
}

export function removeDeadSymlinksVerbose(
  symlinks: readonly SymlinkPath[],
  { dryRun }: RemoveDeadSymlinksOption,
): SymlinkPath[] {
  return removeDeadSymlinks(symlinks, {
    dryRun,
    onStart: () => console.log(colors.brightYellow.bold("Checking dead symlinks...")),
    onDeadlinkFound: (filepath) =>
      console.log(
        colors.cyan("[INFO] remove dead symlink:"),
        colors.yellow(fs.abbrHomePathToTilde(filepath)),
      ),
    onFinish: (deadLinkCount) =>
      console.log(
        deadLinkCount === 0
          ? colors.green.bold("[OK] No dead symlinks found.")
          : colors.green.bold(`[OK] Removed ${deadLinkCount} dead symlinks.`),
      ),
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

type ApplyRepoDotfilesOption = {
  strategy: "symlink" | "copy";
  backupDir: string;
  dryRun?: boolean;
};

type ApplyRepoDotfilesOptionWithHook = ApplyRepoDotfilesOption & {
  onStart?: (gitRootAbsPath: Path) => void;
  beforeApply?: (repoFile: Path, dest: Path) => void;
  afterApplySuccess?: (repoFile: Path, dest: Path) => void;
  beforeBackup?: (orig: Path, backup: Path) => void;
  afterBackupSuccess?: (orig: Path, backup: Path) => void;
  onFinish?: (appliedCount: number) => void;
};

async function applyRepoDotfiles(opt: ApplyRepoDotfilesOptionWithHook) {
  const { strategy, backupDir, dryRun } = opt;
  const HOME = Deno.env.get("HOME")!;
  const gitRootAbsPath = await fetchGitRootAbsPath();
  opt.onStart?.(gitRootAbsPath);

  const dotfiles = await fetchGitTrackedFileList(CONTENT_ROOT);
  const symlinkTargets = calcOptimizedSymlinkTargets(dotfiles);

  const usingSymlink = strategy === "symlink";
  const applyFn = usingSymlink ? Deno.symlinkSync : Deno.copyFileSync;
  let appliedCount = 0;

  symlinkTargets.forEach((dotfile) => {
    const repoFile = path.join(gitRootAbsPath, dotfile);
    const dest = dotfile.replace(CONTENT_ROOT, HOME);

    // シンボリックリンク先が既にリポジトリ内の dotfile を指しているならスキップ
    if (usingSymlink && fs.isSameInodeSameDevice(dest, repoFile)) return;
    opt.beforeApply?.(repoFile, dest);

    // dest が存在し、それがシンボリックリンクでないならバックアップへ移動
    if (fs.isFileOrDir(dest, { followSymlink: false })) {
      const backupPath = dotfile.replace(CONTENT_ROOT, backupDir);
      opt.beforeBackup?.(dest, backupPath);
      if (!dryRun) {
        fs.mkdirRecursive(path.dirname(backupPath));
        Deno.renameSync(dest, backupPath);
      }
      opt.afterBackupSuccess?.(dest, backupPath);
    }

    // copy または symlink を適用
    if (!dryRun) {
      fs.ensureRemoved(dest);
      fs.mkdirRecursive(path.dirname(dest));
      applyFn(repoFile, dest);
    }
    ++appliedCount;
    opt.afterApplySuccess?.(repoFile, dest);
  });

  opt.onFinish?.(appliedCount);
}

export async function applyRepoDotfilesVerbose(
  { strategy, dryRun, afterApplySuccess }:
    & ApplyRepoDotfilesOption
    & Pick<ApplyRepoDotfilesOptionWithHook, "afterApplySuccess">,
) {
  const backupDir = path.join(
    BACKUP_ROOT,
    datetime.format(new Date(), BACKUP_DATE_FORMAT),
  );

  let gitRootAbsPath: Path;

  await applyRepoDotfiles({
    strategy,
    dryRun,
    backupDir,
    onStart: (s) => gitRootAbsPath = s,
    beforeApply: (repoFile, dest) =>
      console.log(
        dryRun ? " (dry-run)" : "",
        colors.magenta(fs.replacePathPrefix(repoFile, gitRootAbsPath, "dotfiles")),
        "->",
        colors.green(fs.abbrHomePathToTilde(dest)),
      ),
    beforeBackup: (_orig, backup) =>
      console.log(
        colors.dim.white(`  ... backup to ${fs.abbrHomePathToTilde(backup)}`),
      ),
    afterApplySuccess,
    onFinish: (appliedCount) =>
      console.log(
        colors.green.bold(`[OK] Applied ${appliedCount} dotfiles using symlink`),
      ),
  });
}

export async function syncDotfilesUsingSymlink({ dryRun }: { dryRun?: boolean }) {
  let symlinks = loadSymlinkState(SYMLINK_STATE_FILE);

  try {
    symlinks = removeDeadSymlinksVerbose(symlinks, { dryRun });

    const backupDir = path.join(
      BACKUP_ROOT,
      datetime.format(new Date(), BACKUP_DATE_FORMAT),
    );

    console.log(); // new line
    await applyRepoDotfilesVerbose({
      strategy: "symlink",
      dryRun,
      backupDir,
      afterApplySuccess: (_repoFile, dest) => symlinks.push(dest),
    });
  } finally {
    if (!dryRun) {
      symlinks = Array.from(new Set(symlinks.sort()));
      saveSymlinkState(SYMLINK_STATE_FILE, symlinks);
    }
  }
}
