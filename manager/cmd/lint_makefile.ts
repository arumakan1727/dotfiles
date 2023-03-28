import { colors, Command } from "../deps.ts";
import { readLinesIntoArray } from "../libs/io.ts";
import { LintError, lintOrphanPhony } from "../libs/makefile_lint.ts";

const command = new Command()
  .name("lint_makefile.ts")
  .description("Simple lint Makefile")
  .arguments("<makefile:file>")
  .action(async (_, makefile) => {
    const errs = await lint(makefile);
    reportErrors(errs);

    if (errs.length === 0) {
      Deno.exit(0);
    } else {
      Deno.exit(255);
    }
  });

export default async function main(args: string[]) {
  await command.parse(args);
}

async function lint(path: string): Promise<LintError[]> {
  const lines = await readLinesIntoArray(path);
  const errs: LintError[] = [];

  errs.push(...lintOrphanPhony(lines, path));

  return errs;
}

function reportErrors(errs: readonly LintError[]) {
  if (errs.length === 0) {
    console.log(colors.green.bold("OK: No lint errors found."));
    return;
  }

  for (const e of errs) {
    console.log(
      colors.yellow(`\n${e.filepath}:${e.lineNo}:${e.colNo}:`),
      colors.yellow.bold(`${e.errName}`),
    );
    console.log("  ", e.message);
  }

  console.log();
  console.log(colors.brightRed(`Found ${errs.length} lint errors`));
}

if (import.meta.main) {
  await main(Deno.args);
}
