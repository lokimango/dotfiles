#!/usr/bin/env bash
# Installer für dieses monochrome Hyprland-Setup.
# Kopiert .config/* nach ~/.config (mit Backup), Programm-Starter nach
# ~/.local/share/applications und legt das Wallpaper ab.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.config-backup-$stamp"

echo ":: Dotfiles aus: $repo"

# 0) Die Hauptconfig ist Lua (hypr/hyprland.lua) -> braucht Hyprland >= 0.55.
#    Nur eine Warnung: beim Erst-Setup ist Hyprland evtl. noch gar nicht installiert.
if command -v Hyprland >/dev/null 2>&1; then
    ver="$(Hyprland --version 2>/dev/null | head -1 | awk '{print $2}')"
    if [ -n "$ver" ] && [ "$(printf '%s\n0.55.0\n' "$ver" | sort -V | head -1)" != "0.55.0" ]; then
        echo "!! Hyprland $ver ist zu alt: hyprland.lua braucht mindestens 0.55."
    fi
fi

# 1) Vorhandene Zielordner sichern
mkdir -p "$backup"
for d in "$repo"/.config/*/; do
    name="$(basename "$d")"
    if [ -e "$HOME/.config/$name" ]; then
        echo ":: Backup ~/.config/$name -> $backup/"
        cp -r "$HOME/.config/$name" "$backup/"
    fi
done

# 2) Alte hyprlang-Configs entfernen (liegen im Backup). Existiert eine hyprland.lua,
#    ignoriert Hyprland eine daneben liegende hyprland.conf KOMMENTARLOS.
#    hyprlock.conf bleibt: hyprlock nutzt weiterhin das .conf-Format.
for f in hyprland.conf monitors.conf env.conf; do
    if [ -e "$HOME/.config/hypr/$f" ]; then
        echo ":: Entferne altes ~/.config/hypr/$f (ersetzt durch .lua, liegt im Backup)"
        rm -f "$HOME/.config/hypr/$f"
    fi
done

# 3) Configs kopieren (Rechte erhalten -> Skripte bleiben ausführbar)
mkdir -p "$HOME/.config"
cp -r --preserve=mode "$repo"/.config/* "$HOME/.config/"
echo ":: Configs nach ~/.config kopiert."

# 4) Programm-Starter (.desktop) — z. B. xclicker mit erzwungenem XWayland
if [ -d "$repo/.local/share/applications" ]; then
    mkdir -p "$HOME/.local/share/applications"
    cp "$repo"/.local/share/applications/*.desktop "$HOME/.local/share/applications/"
    echo ":: Programm-Starter nach ~/.local/share/applications kopiert."
fi

# Vencord liest seine Einstellungen nur beim Start. Läuft Discord gerade, würde es
# beim nächsten Speichern seinen alten Stand über die neue Datei schreiben.
if pgrep -x Discord >/dev/null 2>&1; then
    echo "!! Discord läuft — jetzt komplett beenden und neu starten,"
    echo "!! sonst überschreibt Vencord die gerade kopierten Einstellungen."
fi

# 5) Wallpaper
mkdir -p "$HOME/Pictures/wallpapers"
cp "$repo/wallpapers/wall.png" "$HOME/Pictures/wallpapers/wall.png"
echo ":: Wallpaper nach ~/Pictures/wallpapers/wall.png kopiert."

echo
echo "Fertig. Backup der alten Configs: $backup"
echo "Zugeschnitten auf: NVIDIA RTX 3060 Ti, Monitor DP-3 2560x1440@240 (siehe README)."
echo "Andere Hardware? Dann ~/.config/hypr/monitors.lua und env.lua anpassen."
echo "Prüfen:  Hyprland --verify-config   (muss 'config ok' melden) — dann neu einloggen."
