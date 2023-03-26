import * as PKG_LIST from "../PKG_LIST.ts";
import { determineInstallCmd, InstallWay } from "../INSTALL_CMD.ts";
import { SupportedSysName } from "../SUPPORTED_SYSTEMS.ts";
import { detectSysName, fetchLinuxDistribName } from "../libs/sys_info.ts";

const scope2pkgs: {
  [scope: string]: Iterable<InstallWay> | (() => Iterable<InstallWay>) | undefined;
} = {
  "cli.all": () => Array.prototype.concat(...Object.values(PKG_LIST.cli)),
  "cli.essentials": PKG_LIST.cli.essentials,
  "cli.extras": PKG_LIST.cli.extras,
  "cli.devs": PKG_LIST.cli.devs,
  "fonts.all": PKG_LIST.fonts,
  "gui.all": PKG_LIST.gui,
};

function printUsage() {
  console.log(`\
USAGE:
  install.ts <SCOPE>

ARGS:
  <SCOPE>: ${Object.keys(scope2pkgs).map((s) => `'${s}'`).join("\n         | ")}
`);
}

export default async function main(args: string[]) {
  if (args.length != 1) {
    console.error("Error: Please specify exactly one argument");
    printUsage();
    Deno.exit(1);
  }
  const pkgScope = args[0];
  const pkgs = selectPkgsOrFatal(pkgScope);
  const sysName = await detectSysName(Deno.build.os, fetchLinuxDistribName);

  for (const pkg of pkgs) {
    const { success } = await install(pkg, sysName, { dryRun: true });
    if (!success) {
      Deno.exit(255);
    }
  }
}

function selectPkgsOrFatal(scope: string): Iterable<InstallWay> {
  const pkgs = scope2pkgs[scope];
  if (pkgs == null) {
    console.error(`Error: invalid scope:`, scope);
    printUsage();
    Deno.exit(1);
  }

  if (pkgs instanceof Function) {
    return pkgs();
  }
  return pkgs;
}

async function install(
  way: InstallWay,
  sysName: SupportedSysName,
  opts: { dryRun: boolean },
): Promise<Deno.ProcessStatus> {
  const cmd = determineInstallCmd(way, sysName);

  console.log();
  console.log(new Date().toISOString(), cmd.join(" "));

  if (opts.dryRun) {
    return { success: true, code: 0 };
  } else {
    return await Deno.run({ cmd }).status();
  }
}

if (import.meta.main) {
  await main(Deno.args);
}
