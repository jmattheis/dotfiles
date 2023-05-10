#!/usr/bin/env bash

WS=$(i3-msg -t get_workspaces  | jq '.[] | select(.focused).num')
NEXTID=$(i3-msg -t get_tree | jq --arg WS $WS '.. | select(.type? == "workspace") | select(.num == ($WS | tonumber)) | .. | select(.type? == "con") | select(.window? != null)' | jq -s 'map({id, focused}) | sort_by(.id) | .[(map(.focused == true)|index(true)+1)%(.|length)].id')
i3-msg "[con_id=\"$NEXTID\"] focus"
