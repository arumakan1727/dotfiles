import { readLines } from "https://deno.land/std@0.181.0/io/read_lines.ts";

export async function readLinesIntoArray(path: string): Promise<string[]> {
  const f = await Deno.open(path);
  const lines: string[] = [];
  try {
    for await (const l of readLines(f)) {
      lines.push(l);
    }
  } finally {
    f.close();
  }
  return lines;
}
