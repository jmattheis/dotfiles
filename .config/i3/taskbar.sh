#!/usr/bin/env bash

# See ./polybar.sh
MONIOR=$MONITOR

windows() {
    ACTIVE=$(i3-msg -t get_workspaces  | jq --arg M "$MONITOR" '.[] | select(.visible and .output == $M).num')

    i3-msg -t get_tree \
       | jq --arg A "$ACTIVE" '.. | select(.type? == "workspace") | select(.num == ($A|tonumber))' \
       | jq '.. | select(has("window_properties")?) | {id: .id, focused, name: .window_properties.class | ascii_downcase}' \
       | jq -rs \
           'map("%{A1:i3-msg '"'"'[con_id=\"\(.id)\"] focus'"'"':}" +
              if .focused
                then "%{B#a89984}%{F#282828} \(.name) %{F-}%{B-}"
                else "%{B#3C3836}%{F#BDAE93} \(.name) %{F-}%{B-}"
              end + "%{A}"
            ) | join(" ")'
}
windows

i3-msg -t subscribe -m '[ "window" ]' |
    while IFS= read -r _; do
        windows
    done
