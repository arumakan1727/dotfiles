import { Command } from "../deps.ts";
import { syncDotfilesUsingSymlink } from "../lib/dotfile_manager.ts";

export const subcmdSync = new Command()
  .description(
    "sync dotfiles into your HOME dir, and remove dead symlink automatically",
  )
  .option("--dry-run", "Dry run")
  .action(syncDotfilesUsingSymlink);

export const rootCommand = new Command()
  .name("dotfile")
  .description("dotfile manage tool")
  .globalEnv("NO_COLOR", "Disable colored output")
  .action(() => {
    rootCommand.showHelp();
  })
  .command("sync", subcmdSync);

function main(args: string[]) {
  rootCommand.parse(args);
}

if (import.meta.main) {
  main(Deno.args);
}
