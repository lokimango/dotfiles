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

# Bild beim Bereichs-Auswählen einfrieren (angenehmer beim Ziehen).
# Braucht 'hyprpicker' — fehlt es, überspringt grimblast das Einfrieren KOMMENTARLOS.
#
# KOSTEN (gemessen, 2560x1440@240): hyprpicker legt eine bildschirmfüllende
# Fläche auf und drückt die Bildrate konstant auf ~34 FPS — schon bei reiner
# Mausbewegung, ohne Freeze wären es 240. Ursache ist der langsame CPU-Puffer-
# Pfad auf Nvidia, nicht behebbar. Bewusst akzeptiert: Einfrieren ist es wert.
# Abschalten? Dann einfach:  freeze=""
freeze=""; [ "$target" = "area" ] && freeze="--freeze"

# slurp zeichnet per Default eine halbtransparente Abdunklung über den GANZEN
# Bildschirm und schneidet die Auswahl als Loch hinein. Jede Rechteck-Änderung
# überträgt diese Fläche komplett neu — auf Nvidia der langsame CPU-Puffer-Pfad.
#
# Gemessen (2560x1440@240), Ziehen des Rechtecks:
#   ohne Freeze, mit Abdunklung : 30 FPS
#   ohne Freeze, ohne Abdunklung: 65 FPS
#   MIT Freeze, mit Abdunklung  : 25-36 FPS
#   MIT Freeze, ohne Abdunklung : 34 FPS   <- kein echter Gewinn
# Da oben das Einfrieren aktiv ist, dominiert hyprpicker ohnehin: Die Abdunklung
# bleibt an, weil sie hier nichts kostet. Nur sinnvoll, wenn Freeze aus ist:
# export SLURP_ARGS="-b 00000000"

if grimblast $freeze copysave "$target" "$file"; then
    notify-send -a "Screenshot" -u low -t 2500 -i "$file" \
        "Screenshot · $label" "$(basename "$file")  ->  Zwischenablage"
else
    # Auswahl abgebrochen o. Ae.: evtl. leere Datei entfernen, kurz melden
    [ -f "$file" ] && [ ! -s "$file" ] && rm -f "$file"
    notify-send -a "Screenshot" -u low -t 1800 "Screenshot abgebrochen"
fi
