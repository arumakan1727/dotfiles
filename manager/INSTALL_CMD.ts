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

export type InstallWay =
  | { id: string; cmd?: never; shUrl?: never } & { [k in PackageManager]?: string }
  | { id: string; cmd: readonly string[]; shUrl?: never }
  | { id: string; cmd?: never; shUrl: string; github?: true };

export const determineInstallCmd = (
  pkg: InstallWay,
  sysName: SupportedSysName,
): string[] => {
  const pkgManager = pkgManagerOf[sysName];

  if (pkg.cmd != null) {
    return [...pkg.cmd];
  } else if (pkg.shUrl != null) {
    const urlPrefix = pkg.github ? "https://raw.githubusercontent.com/" : "";
    return ["sh", "-c", `curl -fsSL '${urlPrefix}${pkg.shUrl}' | bash`];
  } else {
    const args = installCmdOf[pkgManager];
    const pkgName = pkg[pkgManager] ?? pkg.id;
    return [...args, pkgName];
  }
};
