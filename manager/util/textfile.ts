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
