#!/usr/bin/env bash
# Installer für dieses monochrome Hyprland-Setup.
# Kopiert .config/* nach ~/.config (mit Backup) und legt das Wallpaper ab.
set -euo pipefail

repo="$(cd "$(dirname "$0")" && pwd)"
stamp="$(date +%Y%m%d-%H%M%S)"
backup="$HOME/.config-backup-$stamp"

echo ":: Dotfiles aus: $repo"

# 1) Vorhandene Zielordner sichern
mkdir -p "$backup"
for d in "$repo"/.config/*/; do
    name="$(basename "$d")"
    if [ -e "$HOME/.config/$name" ]; then
        echo ":: Backup ~/.config/$name -> $backup/"
        cp -r "$HOME/.config/$name" "$backup/"
    fi
done

# 2) Configs kopieren (Rechte erhalten -> Skripte bleiben ausführbar)
mkdir -p "$HOME/.config"
cp -r --preserve=mode "$repo"/.config/* "$HOME/.config/"
echo ":: Configs nach ~/.config kopiert."

# 3) Wallpaper
mkdir -p "$HOME/Pictures/wallpapers"
cp "$repo/wallpapers/wall.png" "$HOME/Pictures/wallpapers/wall.png"
echo ":: Wallpaper nach ~/Pictures/wallpapers/wall.png kopiert."

echo
echo "Fertig. Backup der alten Configs: $backup"
echo "Jetzt anpassen: ~/.config/hypr/monitors.conf und ~/.config/hypr/env.conf"
echo "(siehe README) — dann neu einloggen."
