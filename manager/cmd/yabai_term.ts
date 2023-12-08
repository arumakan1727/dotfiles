/*
 * yabai コマンドを用いて、 id の最も小さい WezTerm ウィンドウの表示・非表示をトグルする。
 * また、is-float, is-topmost, is-sticky を全て true にする。
 *    is-float=true   ->  タイル配置を無効化
 *    is-topmost=true ->  他のウィンドウと被る時に常に最上位に表示
 *    is-sticky=true  ->  全てのワークスペースに表示
 * これにより、ドロップダウンターミナルのような挙動を再現できる。
 */

type WindowID = number;

/** `yabai -m query windows` で得られる要素のスキーマ */
type WindowInfo = {
  id: WindowID;
  pid: number;
  app: string;
  title: string;
  display: number;
  space: number;
  "can-move": boolean;
  "can-resize": boolean;
  "has-focus": boolean;
  "has-shadow": boolean;
  "has-border": boolean;
  "has-parent-zoom": boolean;
  "has-fullscreen-zoom": boolean;
  "is-native-fullscreen": boolean;
  "is-visible": boolean;
  "is-minimized": boolean;
  "is-hidden": boolean;
  "is-floating": boolean;
  "is-sticky": boolean;
  "is-topmost": boolean;
  "is-grabbed": boolean;
};

/** `yabai -m spaces` で得られる要素のスキーマ */
type SpaceInfo = {
  id: number;
  uuid: string;
  index: number;
  label: string;
  type: string;
  display: number;
  windows: WindowID[];
  "first-window": WindowID;
  "last-window": WindowID;
  "has-focus": boolean;
  "is-visible": boolean;
  "is-native-fullscreen": boolean;
};

async function queryYabaiWindowInfos(spaceIndex?: number): Promise<WindowInfo[]> {
  const args = ["-m", "query", "--windows"];
  if (spaceIndex !== undefined) {
    args.push("--space", spaceIndex.toString());
  }

  const yabai = new Deno.Command("yabai", { args, stderr: "inherit" });
  const { success, code, stdout } = await yabai.output();
  if (!success) {
    throw new Error(`failed to run: exitcode=${code}: yabai ${args.join(" ")}`);
  }

  const winInfos = JSON.parse(new TextDecoder().decode(stdout));
  return winInfos;
}

async function queryYabaiSpaceInfos(): Promise<SpaceInfo[]> {
  const args = ["-m", "query", "--spaces"];
  const yabai = new Deno.Command("yabai", { args, stderr: "inherit" });
  const { success, code, stdout } = await yabai.output();
  if (!success) {
    throw new Error(`failed to run: exitcode=${code}: yabai ${args.join(" ")}`);
  }

  return JSON.parse(new TextDecoder().decode(stdout));
}

async function fetchMinimumIDWinInfo(targetAppName: string): Promise<WindowInfo> {
  const winInfos = await queryYabaiWindowInfos();
  const ws = winInfos
    .filter((w) => w.app === targetAppName)
    .sort((a, b) => a.id - b.id);
  return ws[0];
}

async function fetchCurrentSpaceIndex(): Promise<number> {
  const spaceInfos = await queryYabaiSpaceInfos();
  const focusedSpace = spaceInfos.filter((s) => s["has-focus"])[0];
  return focusedSpace.index;
}

async function fetchFirstVisibleWin(opt: {
  spaceIndex: number;
  ignoreAppName: string;
}): Promise<WindowInfo | undefined> {
  const { spaceIndex, ignoreAppName } = opt;
  const winInfos = await queryYabaiWindowInfos(spaceIndex);
  const ws = winInfos.filter((w) => w["is-visible"] && w.app !== ignoreAppName);
  return ws.length > 0 ? ws[0] : undefined;
}

async function generateYabaiTermCmd(termWin: WindowInfo): Promise<string[]> {
  const id = termWin.id.toString();
  const cmd: string[] = ["yabai", "-m", "window", id];
  if (!termWin["is-floating"]) cmd.push("--toggle", "float");
  if (!termWin["is-sticky"]) cmd.push("--toggle", "sticky");

  if (!termWin["is-visible"]) {
    cmd.push("--deminimize", id, "--focus", id);
  } else {
    cmd.push("--minimize", id);

    const currentSpace = await fetchCurrentSpaceIndex();
    const visibleWindowInSameSpace = await fetchFirstVisibleWin({
      spaceIndex: currentSpace,
      ignoreAppName: termWin.app,
    });
    if (visibleWindowInSameSpace != null) {
      cmd.push("--minimize", id, "--focus", visibleWindowInSameSpace.id.toString());
    }
  }
  return cmd;
}

async function main() {
  const w = await fetchMinimumIDWinInfo("WezTerm");
  const cmd = await generateYabaiTermCmd(w);
  console.log(cmd.join(" "));

  const p = new Deno.Command(cmd[0], { args: cmd.slice(1), stderr: "inherit" });
  const { code } = await p.output();
  Deno.exit(code);
}

if (import.meta.main) {
  await main();
}
