#!/usr/bin/env node
import { spawn, execSync } from "child_process";

const mapping = { "Microsoft Teams - Preview": "teams" };

const skip = ["Polybar"];

const [, , workspaceID] = process.argv;

const xprop = spawn("xprop", [
  "-root",
  "-spy",
  "_NET_CLIENT_LIST",
  "_NET_ACTIVE_WINDOW",
]);
const leftwm = spawn("leftwm-state", [
  "-w",
  workspaceID,
  "-s",
  '{% assign x = workspace.tags | where: "mine" | first %}{{x.index}}',
]);

let activeDesktop = -1;
let intervalId = -1;

const update = () => {
  const activeWindow = parseInt(
    execSync("xprop -root _NET_ACTIVE_WINDOW")
      .toString()
      .split(" # ")?.[1]
      ?.trim(),
    16
  );

  const line = execSync("wmctrl -lx")
    .toString()
    .split("\n")
    .map((line) =>
      /(0x[0-9abcdef]+)\s+(\d+)\s+(((?!  ).)+)/.exec(line)?.slice(1)
    )
    .filter((match) => !!match)
    .filter(([id, desktop, name]) => activeDesktop === desktop && name)
    .map(([id, desktop, name]) => {
      const parts = name.split(".");
      name = parts[parts.length - 1];
      name = mapping[name] || name;
      return [parseInt(id), desktop, name];
    })
    .filter(
      ([id, desktop, name]) => activeDesktop === desktop && !skip.includes(name)
    )
    .map(([id, desktop, name]) => {
      let left = "%{F#BDAE93}";
      let right = "%{F-}";
      if (id === activeWindow) {
        left = "%{+u}" + left;
        right = right + "%{-u}";
      }

      return `${left} ${name.toLowerCase()} ${right}`;
    })
    .join(" ");
  console.log(line);
};

const scheduleUpdate = () => {
  clearTimeout(intervalId);
  intervalId = setTimeout(update, 50);
};

xprop.stdout.on("data", scheduleUpdate);
leftwm.stdout.on("data", (data) => {
  let newActiveDesktop = data.toString().trim();
  if (newActiveDesktop !== activeDesktop) {
    activeDesktop = newActiveDesktop;
    scheduleUpdate();
  }
});
