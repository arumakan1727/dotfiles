import { io } from "../deps.ts";

export async function readLinesIntoArray(r: Deno.Reader): Promise<string[]> {
  const lines: string[] = [];
  for await (const l of io.readLines(r)) {
    lines.push(l);
  }
  return lines;
}

/**
 * @return line. If it read EOF, returns undefined.
 */
export async function readLine(r: Deno.Reader): Promise<string | undefined> {
  const itr = io.readLines(r);
  const res = await itr.next();
  return res.value;
}
