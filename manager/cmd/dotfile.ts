import { SYMLINK_STATE_FILE } from "../CONFIG.ts";
import { colors, Command } from "../deps.ts";
import { loadSymlinkState, runApply } from "../lib/dotfile_manager.ts";
import { path } from "../util/mod.ts";

export const subcmdApply = new Command()
  .description(
    "Apply dotfiles into your HOME dir, and remove dead symlink automatically",
  )
  .option("--dry-run", "Dry run")
  .option("--copy", "Use copy strategy instead of symlink")
  .action(async (opt) => {
    const { dryRun } = opt;
    const strategy = opt.copy ? "copy" : "symlink";
    await runApply({ strategy, dryRun });
  });

export const subcmdSymlinks = new Command()
  .description("List applied symlinks")
  .option("--abspath", "Show absolute path instead of tilde path")
  .action((opt) => {
    const links = loadSymlinkState(SYMLINK_STATE_FILE);
    if (links.length === 0) {
      console.error(colors.cyan("No symlinks applied."));
    }
    links.forEach((s) => {
      console.log(opt.abspath ? s : path.abbrHomePathToTilde(s));
    });
  });

export const rootCommand = new Command()
  .name("dotfile")
  .description("dotfile manage tool")
  .globalEnv("NO_COLOR", "Disable colored output")
  .action(() => {
    rootCommand.showHelp();
  })
  .command("apply", subcmdApply)
  .command("symlinks", subcmdSymlinks);

function main(args: string[]) {
  rootCommand.parse(args);
}

if (import.meta.main) {
  main(Deno.args);
}
