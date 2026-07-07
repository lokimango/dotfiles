#!/usr/bin/env bash
# Screenshot -> ~/Pictures/Screenshots + Zwischenablage + dezente Notification
# Nutzung: screenshot.sh [region|window|full]
set -uo pipefail

mode="${1:-region}"
dir="$HOME/Pictures/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case "$mode" in
    region) target="area";   label="Bereich"  ;;
    window) target="active"; label="Fenster"   ;;
    full)   target="output"; label="Vollbild"  ;;
    *)      target="area";   label="Bereich"   ;;
esac

# Bild beim Bereichs-Auswählen einfrieren (angenehmer beim Ziehen)
freeze=""; [ "$target" = "area" ] && freeze="--freeze"

if grimblast $freeze copysave "$target" "$file"; then
    notify-send -a "Screenshot" -u low -t 2500 -i "$file" \
        "Screenshot · $label" "$(basename "$file")  ->  Zwischenablage"
else
    # Auswahl abgebrochen o. Ae.: evtl. leere Datei entfernen, kurz melden
    [ -f "$file" ] && [ ! -s "$file" ] && rm -f "$file"
    notify-send -a "Screenshot" -u low -t 1800 "Screenshot abgebrochen"
fi
