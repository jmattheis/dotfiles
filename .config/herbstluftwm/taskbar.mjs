#!/usr/bin/env node
import { spawn, execSync } from "child_process";

const MONITOR = process.env.MONITOR;

const MONITOR_INDEX = execSync("polybar --list-monitors")
  .toString()
  .trim()
  .split("\n")
  .findIndex((line) => line.startsWith(MONITOR));

const print = () => {
  const clients = execSync(
    `herbstclient list_clients --monitor=${MONITOR_INDEX}`
  )
    .toString()
    .trim()
    .split("\n");

  const attr = (id, name) =>
    execSync(`herbstclient attr clients.${id}.${name}`).toString().trim();
  const focused = attr("focus", "winid");

  const data = clients
    .map((client) => {
      const flags = {
        m: "minimized",
        p: "pseudotile",
        u: "urgent",
      };
      return {
        id: client,
        name: attr(client, "class"),
        flags: Object.entries(flags)
          .filter(([, name]) => attr(client, name) === "true")
          .map(([key]) => key),
      };
    })
    .map(({ id, name, flags }) => {
      let left = "%{F#BDAE93}";
      let right = "%{F-}";
      if (id === focused) {
        left = "%{+u}" + left;
        right = right + "%{-u}";
      }

      const suffix = flags.length ? `*${flags.join("")}` : "";

      return `${left} ${name.toLowerCase()}${suffix} ${right}`;
    });
  console.log(data.join(" "));
};
print();
let timeoutHandle = -1;
const schedule = () => {
  clearTimeout(timeoutHandle);
  timeoutHandle = setTimeout(print, 5);
};

spawn("herbstclient", ["--idle", "tag_*|focus_*"]).stdout.on("data", schedule);
