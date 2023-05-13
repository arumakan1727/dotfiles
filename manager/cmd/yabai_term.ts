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

async function fetchMinimumIDWinInfo(targetAppName: string): Promise<WindowInfo> {
  const yabai = new Deno.Command("yabai", {
    args: ["-m", "query", "--windows"],
    stdin: "inherit",
    stdout: "piped",
    stderr: "inherit",
  }).spawn();

  const jq = new Deno.Command("jq", {
    args: [
      "-r",
      [
        `[.[] | select(.app | contains("${targetAppName}"))]`,
        "sort_by(.id)",
        ".[0]",
        `{ ${windowInfoProps.map((s) => `"${s}"`).join(", ")} }`,
      ].join(" | "),
    ],
    stdin: "piped",
    stdout: "piped",
    stderr: "inherit",
  }).spawn();

  yabai.stdout.pipeTo(jq.stdin);
  {
    const { success, code } = await yabai.status;
    if (!success) throw new Error(`failed to run: \`yabai\` returned ${code}`);
  }
  {
    const { success, code, stdout } = await jq.output();
    if (!success) throw new Error(`failed to run: \`jq\` returned ${code}`);
    const res = new TextDecoder().decode(stdout);
    return JSON.parse(res);
  }
}

function generateYabaiTermCmd(w: WindowInfo): string[] {
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
  const w = await fetchMinimumIDWinInfo("WezTerm");
  const cmd = generateYabaiTermCmd(w);
  console.log(cmd.join(" "));

  const p = new Deno.Command(cmd[0], { args: cmd.slice(1), stderr: "inherit" });
  const { code } = await p.output();
  Deno.exit(code);
}

if (import.meta.main) {
  await main();
}
