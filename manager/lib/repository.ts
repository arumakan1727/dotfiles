import { io, path } from "../deps.ts";
import * as ioutil from "../util/io.ts";

function getModuleDir(importMeta: ImportMeta): string {
  return path.resolve(path.dirname(path.fromFileUrl(importMeta.url)));
}

export async function fetchGitRootAbsPath(): Promise<string> {
  const selfDir = getModuleDir(import.meta);
  const cmd = [
    "git",
    "-C",
    selfDir,
    "rev-parse",
    "--show-superproject-working-tree",
    "--show-toplevel",
  ];

  const p = Deno.run({ cmd, stdout: "piped" });
  let stdout1stLine: string | undefined;
  try {
    stdout1stLine = await ioutil.readLine(p.stdout);

    const { success } = await p.status();
    if (stdout1stLine == null || !success) {
      throw new Error(`failed to fetch git root path: cmd: '${cmd.join(" ")}'`);
    }
  } finally {
    p.stdout.close();
    p.close();
  }
  return stdout1stLine.trim();
}

export async function fetchGitTrackedFileList(
  startPointDir: string,
): Promise<string[]> {
  const gitRootDir = await fetchGitRootAbsPath();
  const cmd = ["git", "-C", gitRootDir, "ls-files", startPointDir];

  const p = Deno.run({ cmd, stdout: "piped" });
  let res: string[];
  try {
    res = await ioutil.readLinesIntoArray(p.stdout);
  } finally {
    p.stdout.close();
    p.close();
  }

  return res;
}
