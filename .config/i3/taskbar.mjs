#!/usr/bin/env node
import { spawn, execSync } from "child_process";

const MONITOR = process.env.MONITOR;

const print = () => {
  const workspaces = JSON.parse(
    execSync("i3-msg -t get_workspaces").toString().trim()
  );
  const wsNum = workspaces.find(
    (ws) => ws.visible && ws.output === MONITOR
  ).num;

  const windows = JSON.parse(
    execSync(
      `i3-msg -s $(i3 --get-socketpath) -t get_tree  | jq '.. | select(.type? == "workspace") | select(.num == ${wsNum}) | .. | select(has("window_properties")?) | {id: .id, urgent, focused, name: .window_properties.class}' | jq -s`
    ).toString()
  );
  const data = windows.map(({ id, focused, name }) => {
    let left = "%{B#3C3836}%{F#BDAE93}";
    let right = "%{F-}%{B-}";
    if (focused) {
      left = "%{B#a89984}%{F#282828}";
      right = "%{F-}%{B-}";
    }

    const cmd = `i3-msg '[con_id="${id}"] focus'`;

    return `%{A1:${cmd}:}${left} ${name.toLowerCase()} ${right}%{A}`;
  });
  console.log(data.join(" "));
};
print();

let timeoutHandle = -1;
const schedule = () => {
  clearTimeout(timeoutHandle);
  timeoutHandle = setTimeout(print, 15);
};

spawn("i3-msg", ["-t", "subscribe", "-m", '[ "window" ]']).stdout.on(
  "data",
  schedule
);
