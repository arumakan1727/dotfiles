import { SupportedSysName } from "../SUPPORTED_SYSTEMS.ts";
import { ErrUnsupportedDistrib, ErrUnsupportedOS } from "./errors.ts";

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
