import { io } from "../deps.ts";

export class ErrCannotFindLinuxDistirb extends Error {
  constructor(filepath: string, why: "file not found" | "distrib entry not found") {
    super(`${why}: ${filepath}`);
    this.name = "ErrCannotFindLinuxDistirb";
  }
}

const extractLinuxDistribName = async (r: Deno.Reader): Promise<string | undefined> => {
  for await (const line of io.readLines(r)) {
    const m = line.match(/^NAME\s*=\s*['"]?([^'"]+)['"]?/);
    if (m) return m[1];
  }
  return undefined;
};

export const fetchLinuxDistribName = async (): Promise<string> => {
  const filepath = "/etc/os-release";
  let f: Deno.FsFile;
  try {
    f = await Deno.open(filepath);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      throw new ErrCannotFindLinuxDistirb(filepath, "file not found");
    }
    throw e;
  }

  let distribName: string | undefined;
  try {
    distribName = await extractLinuxDistribName(f);
  } finally {
    f.close();
  }
  if (distribName == null) {
    throw new ErrCannotFindLinuxDistirb(filepath, "distrib entry not found");
  }
  return distribName;
};
