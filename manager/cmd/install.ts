import * as PKG_LIST from "../PKG_LIST.ts";
import { determineInstallCmd, dotfilesCacheHome, InstallWay } from "../INSTALL_CMD.ts";
import { SupportedSysName } from "../SUPPORTED_SYSTEMS.ts";
import { detectSysName, fetchLinuxDistribName } from "../libs/sys_info.ts";
import { colors, Command, datetime, EnumType, path } from "../deps.ts";
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

type CmdOptions = {
  reinstallHours: number;
  dryRun?: true;
  noColor?: unknown;
};
type CmdArgs = {
  0: Scope;
};

const command = new Command()
  .name("install.ts")
  .description("Install packages - cli, gui, fonts, ... etc.")
  .env("NO_COLOR=<value:any>", "Disable colored output")
  .option("--dry-run", "Do not actually install, just show output")
  .option(
    "--reinstall-hours <type:number>",
    "Skip installation if the time since last installation of the package is less than this value",
    {
      default: 24,
    },
  )
  .type(
    "scope",
    new EnumType(Object.keys(scope2pkgs)) as EnumType<Scope>,
  )
  .arguments("<scope:scope>");

export default async function main(args: string[]) {
  const { options, args: parsedArgs } = await command.parse(args);

  const lastInstall = loadLastInstallDateRecord();
  let exitCode = 0;
  try {
    exitCode = await run(options, parsedArgs, lastInstall);
  } finally {
    saveLastInstallDateRecord(lastInstall);
  }
  Deno.exit(exitCode);
}

type PackageID = string;
type LastInstallDateRecord = Record<PackageID, Date | undefined>;

function diffHours(from: Date, to: Date): number {
  return datetime.difference(from, to, { units: ["hours"] }).hours!;
}

async function run(
  opt: CmdOptions,
  args: CmdArgs,
  lastInstall: LastInstallDateRecord,
): Promise<number> {
  const scope = args[0];
  const pkgs = selectPkgs(scope);
  const sysName = await detectSysName(Deno.build.os, fetchLinuxDistribName);
  const now = new Date();

  for (let i = 0; i < pkgs.length; ++i) {
    const pkg = pkgs[i];

    const { success } = await install(pkg, sysName, now, lastInstall[pkg.id], {
      dryRun: opt.dryRun ?? false,
      reinstallHours: opt.reinstallHours,
      outputPrefix: `[${i + 1}/${pkgs.length}]`,
    });
    if (!success) {
      return 1;
    }
    if (!opt.dryRun) {
      lastInstall[pkg.id] = new Date();
    }
  }

  console.log(
    "\n",
    colors.green(`Successflly installed ${pkgs.length} packages! Good bye👋`),
  );
  return 0;
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
  now: Date,
  lastInstalledAt: Date | undefined,
  opt: { dryRun: boolean; reinstallHours: number; outputPrefix: string },
): Promise<Deno.ProcessStatus> {
  const cmd = determineInstallCmd(way, sysName);

  console.log(
    `\n` + opt.outputPrefix,
    colors.magenta(new Date().toLocaleTimeString()),
    colors.brightYellow.bold(way.id) + ":",
    colors.cyan((cmd[0] === "sh" && cmd[1] === "-c" ? cmd.slice(2) : cmd).join(" ")),
  );

  if (
    lastInstalledAt != null && diffHours(lastInstalledAt, now) < opt.reinstallHours
  ) {
    console.log(
      colors.blue(
        `[SKIP] This package has already been installed within ${opt.reinstallHours} hours`,
      ),
    );
    return { success: true, code: 0 };
  }

  if (opt.dryRun) {
    return { success: true, code: 0 };
  } else {
    return await Deno.run({ cmd }).status();
  }
}

const lastInstallDateRecordPath = path.join(
  dotfilesCacheHome,
  "last-install-date.json",
);

function loadLastInstallDateRecord(): LastInstallDateRecord {
  let fileContent = "";
  try {
    fileContent = Deno.readTextFileSync(lastInstallDateRecordPath);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) return {};
  }
  const o = JSON.parse(fileContent || "{}");
  for (const key in o) {
    o[key] = new Date(o[key]);
  }
  return o;
}

function saveLastInstallDateRecord(record: LastInstallDateRecord) {
  const jsonPath = lastInstallDateRecordPath;
  Deno.mkdirSync(path.dirname(jsonPath), { recursive: true });
  Deno.writeTextFileSync(jsonPath, JSON.stringify(record));
}

if (import.meta.main) {
  await main(Deno.args);
}
