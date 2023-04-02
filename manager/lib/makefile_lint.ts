import { colors } from "../deps.ts";

export enum LintErrCode {
  OrphanPhony = "E101:orphan-phony",
}

export interface LintError {
  errName: LintErrCode;

  filepath: string;

  /** line number (1-indexed) */
  lineNo: number;

  /** column number (1-indexed) */
  colNo: number;

  message: string;
}

export function lintOrphanPhony(
  lines: readonly string[],
  filepath: string,
): LintError[] {
  const errs: LintError[] = [];

  for (let i = 0; i < lines.length; ++i) {
    const curLine = lines[i];
    const nextLine = lines[i + 1] ?? "";
    const phonyMatch = curLine.match(/^.PHONY:\s*(\S+)/);
    if (phonyMatch == null) continue;

    const phonyTargetName = phonyMatch[1];
    const match = nextLine.match(/^(\S+):/);
    if (match == null || match[1] !== phonyTargetName) {
      errs.push({
        errName: LintErrCode.OrphanPhony,
        filepath,
        lineNo: i + 1,
        colNo: 1,
        message: `expected task def '${colors.cyan(phonyTargetName)}'` +
          ` for the next line, but got '${nextLine ? colors.yellow(nextLine) : ""}'`,
      });
    }
  }
  return errs;
}
