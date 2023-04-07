/*
 * yabai コマンドを用いて、 id の最も小さい WezTerm ウィンドウの表示・非表示をトグルする。
 * また、is-float, is-topmost, is-sticky を全て true にする。
 *    is-float=true   ->  タイル配置を無効化
 *    is-topmost=true ->  他のウィンドウと被る時に常に最上位に表示
 *    is-sticky=true  ->  全てのワークスペースに表示
 * これにより、ドロップダウンターミナルのような挙動を再現できる。
 */
import { streams } from "../deps.ts";

const windowInfoMock = {
  id: 1,
  "is-visible": false,
  "is-floating": false,
  "is-sticky": false,
  "is-topmost": false,
};

const windowInfoProps: readonly string[] = Object.keys(windowInfoMock);
type WindowInfo = typeof windowInfoMock;

const yabaiCmd = ["yabai", "-m", "query", "--windows"] as const;

const jqCmd = [
  "jq",
  "-r",
  [
    '[.[] | select(.app | contains("WezTerm"))]',
    "sort_by(.id)",
    ".[0]",
    `{ ${windowInfoProps.map((s) => `"${s}"`).join(", ")} }`,
  ].join(" | "),
] as const;

async function fetchMinimumIDWezTermWinInfo(): Promise<WindowInfo> {
  const yabai = Deno.run({
    cmd: yabaiCmd,
    stdout: "piped",
  });
  const jq = Deno.run({
    cmd: jqCmd,
    stdin: "piped",
    stdout: "piped",
  });

  let res: string;
  try {
    await streams.copy(yabai.stdout, jq.stdin);
    {
      const { success } = await yabai.status();
      if (!success) throw new Error(`failed to run: '${yabaiCmd.join()}'`);
    }

    jq.stdin.close();
    res = new TextDecoder().decode(await jq.output());
    {
      const { success } = await jq.status();
      if (!success) throw new Error(`failed to run: '${jqCmd.join()}'`);
    }
  } finally {
    yabai.close();
    jq.close();
  }
  return JSON.parse(res);
}

function generateYabaiTermCmd(w: WindowInfo) {
  const id = w.id.toString();
  const cmd: string[] = ["yabai", "-m", "window", id];
  if (!w["is-floating"]) cmd.push("--toggle", "float");
  if (!w["is-sticky"]) cmd.push("--toggle", "sticky");
  if (!w["is-topmost"]) cmd.push("--toggle", "topmost");
  if (w["is-visible"]) {
    cmd.push("--minimize", id, "--focus", "recent");
  } else {
    cmd.push("--deminimize", id, "--focus", id);
  }
  return cmd;
}

async function main() {
  const w = await fetchMinimumIDWezTermWinInfo();
  const cmd = generateYabaiTermCmd(w);
  console.log(cmd.join(" "));
  const p = Deno.run({ cmd });

  const { code } = await p.status();
  Deno.exit(code);
}

if (import.meta.main) {
  await main();
}
