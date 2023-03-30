import * as PKG_LIST from "../PKG_LIST.ts";
import { determineInstallCmd, InstallWay } from "../INSTALL_CMD.ts";
import { SupportedSysName } from "../SUPPORTED_SYSTEMS.ts";
import { detectSysName, fetchLinuxDistribName } from "../libs/sys_info.ts";
import { colors, Command, EnumType } from "../deps.ts";
import { concat } from "../libs/collection.ts";

const scope2pkgs = {
  "cli.all": () => concat(...Object.values(PKG_LIST.cli)),
  "cli.essentials": PKG_LIST.cli.essentials,
  "cli.extras": PKG_LIST.cli.extras,
  "cli.devs": PKG_LIST.cli.devs,
  "fonts.all": PKG_LIST.fonts,
  "gui.all": PKG_LIST.gui,
} as const;

type Scope = keyof typeof scope2pkgs;

const command = new Command()
  .name("install.ts")
  .description("Install packages - cli, gui, fonts, ... etc.")
  .env("NO_COLOR=<value:any>", "Disable colored output")
  .option("--dry-run", "Do not actually install, just show output")
  .type(
    "scope",
    new EnumType(Object.keys(scope2pkgs)) as EnumType<Scope>,
  )
  .arguments("<scope:scope>")
  .action(async (opt, scope) => {
    const pkgs = selectPkgs(scope);
    const sysName = await detectSysName(Deno.build.os, fetchLinuxDistribName);

    for (let i = 0; i < pkgs.length; ++i) {
      const pkg = pkgs[i];
      const { success } = await install(pkg, sysName, {
        dryRun: opt.dryRun ?? false,
        outputPrefix: `[${i + 1}/${pkgs.length}]`,
      });
      if (!success) {
        Deno.exit(255);
      }
    }

    console.log(
      "\n",
      colors.green(`Successflly installed ${pkgs.length} packages! Good bye👋`),
    );
  });

export default async function main(args: string[]) {
  await command.parse(args);
}

function selectPkgs(scope: Scope): ReadonlyArray<InstallWay> {
  const pkgs = scope2pkgs[scope];
  if (pkgs instanceof Function) {
    return pkgs();
  }
  return pkgs;
}

async function install(
  way: InstallWay,
  sysName: SupportedSysName,
  opt: { dryRun: boolean; outputPrefix: string },
): Promise<Deno.ProcessStatus> {
  const cmd = determineInstallCmd(way, sysName);

  console.log(
    `\n` + opt.outputPrefix,
    colors.magenta(new Date().toLocaleTimeString()),
    colors.brightYellow.bold(way.id) + ':',
    colors.cyan((cmd[0] === "sh" && cmd[1] === "-c" ? cmd.slice(2) : cmd).join(" ")),
  );

  if (opt.dryRun) {
    return { success: true, code: 0 };
  } else {
    return await Deno.run({ cmd }).status();
  }
}

if (import.meta.main) {
  await main(Deno.args);
}
