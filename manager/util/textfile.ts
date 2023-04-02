import { path } from "../deps.ts";
import * as ioutil from "./io.ts";

export async function readLinesIntoArray(path: string): Promise<string[]> {
  const f = await Deno.open(path);
  let res: string[];
  try {
    res = await ioutil.readLinesIntoArray(f);
  } finally {
    f.close();
  }
  return res;
}

export function readJSON<T>(filepath: string, opt: { fallback: T }): T {
  let content: string;
  try {
    content = Deno.readTextFileSync(filepath);
  } catch (e) {
    if (e instanceof Deno.errors.NotFound) {
      return opt.fallback;
    }
    throw e;
  }
  if (content.trim() === "") {
    return opt.fallback;
  }
  return JSON.parse(content);
}

// deno-lint-ignore no-explicit-any
export function writeJSONWithMkdir(filepath: string, value: any) {
  Deno.mkdirSync(path.dirname(filepath), { recursive: true });
  Deno.writeTextFileSync(filepath, JSON.stringify(value));
}
