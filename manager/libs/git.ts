import { io, path } from "../deps.ts";

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
  let stdout1stLine: string;
  try {
    stdout1stLine = (await io.readLines(p.stdout).next()).value;
  } finally {
    p.stdout.close();
    p.close();
  }
  return stdout1stLine.trim();
}

export async function fetchGitTrackedFileList(
  startPointDir: string,
  opt: { resultPathStyle: "abs" | "rel" },
): Promise<string[]> {
  const gitRootDir = await fetchGitRootAbsPath();
  const cmd = ["git", "-C", gitRootDir, "ls-files", startPointDir];

  const p = Deno.run({ cmd, stdout: "piped" });
  const res: string[] = [];
  const pathPrefix = opt.resultPathStyle === "abs" ? gitRootDir : "";
  try {
    for await (const filepath of io.readLines(p.stdout)) {
      res.push(pathPrefix + filepath);
    }
  } finally {
    p.stdout.close();
    p.close();
  }

  return res;
}
