import { SupportedSysName } from "./SUPPORTED_SYSTEMS.ts";

export type PackageManager = "brew" | "apt";

export const pkgManagerOf: { [k in SupportedSysName]: PackageManager } = {
  Darwin: "brew",
  Ubuntu: "apt",
} as const;

export const installCmdOf: { [k in PackageManager]: string[] } = {
  brew: ["brew", "install"],
  apt: ["sudo", "apt", "install"],
};

export type PackageName = string;

export type InstallWay =
  | ({ [k in PackageManager]: string } & { cmd?: never })
  | { cmd: string[] }
  | PackageName;

export const determineInstallCmd = (
  way: InstallWay,
  sysName: SupportedSysName,
): string[] => {
  const pkgManager = pkgManagerOf[sysName];

  if (typeof way === "string") {
    const pkgName = way;
    const args = installCmdOf[pkgManager];
    return [...args, pkgName];
  } else if (way.cmd != null) {
    return way.cmd;
  } else {
    const args = installCmdOf[pkgManager];
    const pkgName = way[pkgManager];
    return [...args, pkgName];
  }
};
