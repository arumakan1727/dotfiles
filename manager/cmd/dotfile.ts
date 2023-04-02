import { Command } from "../deps.ts";
import { runApply } from "../lib/dotfile_manager.ts";

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

export const rootCommand = new Command()
  .name("dotfile")
  .description("dotfile manage tool")
  .globalEnv("NO_COLOR", "Disable colored output")
  .action(() => {
    rootCommand.showHelp();
  })
  .command("sync", subcmdApply);

function main(args: string[]) {
  rootCommand.parse(args);
}

if (import.meta.main) {
  main(Deno.args);
}
