import { SupportedSysName } from "../SUPPORTED_SYSTEMS.ts";
import { io } from "../deps.ts";
import {
  ErrCannotFindLinuxDistirb,
  ErrUnsupportedDistrib,
  ErrUnsupportedOS,
} from "./errors.ts";

const extractLinuxDistribName = async (r: Deno.Reader): Promise<string | null> => {
  for await (const line of io.readLines(r)) {
    const m = line.match(/^NAME\s*=\s*['"]?([^'"]+)['"]?/);
    if (m) return m[1];
  }
  return null;
};

export const fetchLinuxDistribName = async (): Promise<string> => {
  const filepath = "/etc/os-release";
  let f: Deno.FsFile | undefined;
  let distribName: string | null = null;

  try {
    f = await Deno.open(filepath);
    distribName = await extractLinuxDistribName(f);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      throw new ErrCannotFindLinuxDistirb(filepath, "file not found");
    }
  } finally {
    f && f.close();
  }

  if (distribName == null) {
    throw new ErrCannotFindLinuxDistirb(filepath, "distrib entry not found");
  }
  return distribName;
};

export const detectSysName = async (
  os: typeof Deno.build.os,
  distribName: () => Promise<string>,
): Promise<SupportedSysName> => {
  if (os === "darwin") return "Darwin";
  if (os !== "linux") throw new ErrUnsupportedOS(os);

  const d = await distribName();
  switch (d.toLowerCase()) {
    case "ubuntu":
      return "Ubuntu";
  }

  throw new ErrUnsupportedDistrib(d);
};
