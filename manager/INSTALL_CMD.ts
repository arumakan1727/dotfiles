import { SupportedSysName } from "./SUPPORTED_SYSTEMS.ts";
import { path } from "./deps.ts";

const env = Deno.env.get;

export const dotfilesCacheHome = path.join(
  env("XDG_CACHE_HOME") ?? path.join(env("HOME")!, ".cache"),
  "armkn-dotfiles",
);

export type PackageManager = "brew" | "apt";

export const pkgManagerOf: Record<SupportedSysName, PackageManager> = {
  Darwin: "brew",
  Ubuntu: "apt",
} as const;

export const installCmdOf: Record<PackageManager, readonly string[]> = {
  brew: ["brew", "install"],
  apt: ["sudo", "apt", "install"],
} as const;

export type InstallWay =
  | { id: string; cmd?: never; shUrl?: never } & { [k in PackageManager]?: string }
  | { id: string; cmd: readonly string[]; shUrl?: never }
  | { id: string; cmd?: never; shUrl: string; github?: boolean; sh?: "sh" | "bash" };

export const determineInstallCmd = (
  pkg: InstallWay,
  sysName: SupportedSysName,
): string[] => {
  const pkgManager = pkgManagerOf[sysName];

  if (pkg.cmd != null) {
    return [...pkg.cmd];
  } else if (pkg.shUrl != null) {
    const urlPrefix = pkg.github ? "https://raw.githubusercontent.com/" : "";
    return ["sh", "-c", `curl -fsSL '${urlPrefix}${pkg.shUrl}' | ${pkg.sh ?? "sh"}`];
  } else {
    const args = installCmdOf[pkgManager];
    const pkgName = pkg[pkgManager] ?? pkg.id;
    return [...args, pkgName];
  }
};
