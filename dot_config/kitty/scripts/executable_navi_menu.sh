#!/bin/sh
# Two-step navi: pick a category (cheat tag), then a command from it.
# Esc on the command list steps back to categories; Esc there closes the split.
# $1 = kitty window id to paste the result into.
set -e

cheats=$(navi info cheats-path)

while :; do
    tag=$(grep -h '^%' "$cheats"/*.cheat 2>/dev/null |
        sed 's/^% *//; s/, */\n/g' | sed '/^$/d' | sort -u |
        fzf --prompt='category> ' --height=100% --layout=reverse) || exit 0
    [ -n "$tag" ] || exit 0

    # tag column is redundant once a category is picked: hide it, keep the rest
    cmd=$(navi --print --query "$tag" --fzf-overrides '--with-nth=2..') || continue
    [ -n "$cmd" ] || continue

    kitty @ send-text --match "id:$1" -- "$cmd"
    exit 0
done
