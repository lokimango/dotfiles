# dotfiles

Minimalistisches, **monochromes** Hyprland-Setup (dunkel, Graustufen, Terminal-/Hacker-Look) —
der genaue Stand meines **Desktop-PCs**: CachyOS (Arch) + Hyprland (Wayland) auf NVIDIA.

![Look](wallpapers/wall.png)

> **Hyprland ≥ 0.55 nötig.** Die Hauptconfig ist **Lua** (`hypr/hyprland.lua`) — das alte
> `.conf`-Format fällt mit Hyprland 0.57 weg. Getestet mit 0.56.

## Enthaltene Konfigurationen

| Ordner | Programm | Zweck |
|---|---|---|
| `hypr/` | Hyprland, hyprlock | Compositor, Keybinds, Sperrbildschirm, Autostart, Skripte |
| `waybar/` | Waybar | Statusleiste (schwebend, monochrom) |
| `kitty/` | kitty | Terminal |
| `wlogout/` | wlogout | Power-Menü (Sperren/Abmelden/Suspend/Neustart/Herunterfahren) |
| `fuzzel/` | fuzzel | App-Launcher / dmenu |
| `cliphist/` | cliphist | Zwischenablage-Historie (max. 100 Einträge) |
| `fastfetch/` | fastfetch | Systeminfo |
| `btop/` | btop | Ressourcen-Monitor (Theme `monochrome`) |
| `Vencord/` | Vencord (Discord) | Plugin-Einstellungen (31 aktiv) — nur die Einstellungen, nicht Vencord selbst |
| `polychromatic/` | Polychromatic | Tastatur-RGB: Effekt „Lila" samt Zustand, damit der Autostart ihn wiederherstellt |
| `.local/share/applications/` | xclicker | Starter mit erzwungenem XWayland (siehe Besonderheiten) |

### `hypr/` im Detail

| Datei | Inhalt |
|---|---|
| `hyprland.lua` | Hauptconfig: Autostart, Eingabe, Look, Animationen, Regeln, Keybinds |
| `monitors.lua` | Monitor ⚠ hardwareabhängig |
| `env.lua` | Umgebungsvariablen: Mauszeiger, NVIDIA ⚠ hardwareabhängig |
| `hyprlock.conf` | Sperrbildschirm — bleibt `.conf`, hyprlock nutzt kein Lua |
| `scripts/lock.sh` | Sperren (startet hyprlock nie doppelt, loggt nach `~/hyprlock-debug.log`) |
| `scripts/screenshot.sh` | Screenshots über grimblast, Bereich wird beim Auswählen eingefroren |
| `scripts/clipboard.sh` | Zwischenablage-Auswahl mit Bildvorschau |

---

## Installation

```bash
git clone https://github.com/lokimango/dotfiles.git
cd dotfiles
./install.sh                 # kopiert .config/* nach ~/.config (mit Backup) + Wallpaper
Hyprland --verify-config     # muss "config ok" melden — prüft offline, ohne Neustart
```

Danach neu einloggen.

> `install.sh` sichert vorhandene Zielordner nach `~/.config-backup-<datum>/` und entfernt
> eine alte `hyprland.conf`/`monitors.conf`/`env.conf` (liegen im Backup). Grund: Existiert
> eine `hyprland.lua`, ignoriert Hyprland die `.conf` **kommentarlos**.
>
> **Discord vorher beenden:** Vencord liest seine Einstellungen nur beim Start und würde
> die kopierte Datei sonst beim nächsten Speichern mit dem alten Stand überschreiben.
> `install.sh` warnt, wenn Discord läuft.

---

## Pakete

### Offiziell (pacman)

```bash
sudo pacman -S --needed \
  hyprland hyprlock hypridle \
  waybar kitty fuzzel fastfetch btop \
  swaync swaybg \
  wl-clipboard cliphist imagemagick \
  grim slurp hyprpicker jq \
  brightnessctl playerctl libnotify \
  pipewire-pulse \
  xdg-desktop-portal-hyprland \
  breeze-cursors \
  ttf-jetbrains-mono-nerd
```

- **swaync** – Notification-Daemon (im Autostart) · **swaybg** – Wallpaper
- **wl-clipboard + cliphist** – Zwischenablage-Historie (`Super+V`) · **imagemagick** – Vorschaubilder darin
- **grim + slurp + jq** – von grimblast benötigt · **hyprpicker** – Einfrieren beim Screenshot
  (fehlt es, lässt grimblast das Einfrieren **kommentarlos** weg)
- **playerctl** – Medientasten · **pipewire-pulse** – liefert `pactl` für die Lautstärke-Keybinds
- **breeze-cursors** – Mauszeiger „Breeze Dark" (wie unter KDE)
- **ttf-jetbrains-mono-nerd** – Font inkl. Icons für Waybar/Terminal (zwingend)
- **hypridle** – nur nötig, falls Auto-Sperre gewünscht (hier **nicht** konfiguriert)

### AUR (yay/paru)

```bash
yay -S --needed \
  wlogout \
  grimblast-git
```

Auf CachyOS liegen beide auch direkt im `cachyos`-Repo.

### Nur für die Hardware dieses PCs

| Paket | Wofür |
|---|---|
| `nvidia-open` (CachyOS: `linux-cachyos-nvidia-open`) | GPU-Treiber, Modeset aktiv |
| `openrazer-daemon` + `polychromatic` (AUR) | Tastatur-RGB. Benutzer muss in die Gruppe `openrazer`. Fehlt es, scheitert nur die Autostart-Zeile — harmlos. |

### Apps

| Paket | Wofür |
|---|---|
| Vencord | Über den offiziellen Installer: `sh -c "$(curl -sS https://vencord.dev/install.sh)"` — danach greifen die Einstellungen aus `Vencord/` |
| `xclicker` (AUR) | Autoclicker |

---

## Hardware dieses Setups

| | |
|---|---|
| GPU | NVIDIA RTX 3060 Ti |
| Monitor | `DP-3`, 2560x1440 @ 240 Hz |
| Tastatur | Layout `de` (Razer Huntsman Elite) |
| Maus | `sensitivity = -0.45`, flache Beschleunigung (`accel_profile = "flat"`) |

### Auf anderer Hardware anpassen

| Datei | Was |
|---|---|
| `hypr/monitors.lua` | Monitorname und Modus — `hyprctl monitors` zeigt beides. Generisch: `hl.monitor({ output = "", mode = "preferred", position = "auto", scale = 1 })` |
| `hypr/env.lua` | **NVIDIA-Block entfernen** auf Intel/AMD — vor allem `GBM_BACKEND=nvidia-drm` verhindert dort sonst den Start. `cursor.no_hardware_cursors` kann dort ebenfalls raus. |
| `hypr/hyprland.lua` | `input`: Tastaturlayout, Maus-Empfindlichkeit |
| `hypr/hyprlock.conf` | Wallpaper-Pfad ist absolut (`/home/loki/…`) — bei anderem Benutzernamen anpassen |

---

## Keybinds (Kurzreferenz)

| Taste | Aktion |
|---|---|
| `Super+Return` | Terminal (kitty) |
| `Super+B` | Brave |
| `Super+D` | Launcher (fuzzel) — nochmal drücken schließt |
| `Super+V` | Zwischenablage mit Bildvorschau — nochmal drücken schließt |
| `Super+Escape` | Power-Menü (wlogout) |
| `Super+Q` · `Super+F` · `Super+Shift+F` | Fenster schließen · Vollbild · floaten |
| `Super+P` · `Super+J` | Pseudo-Tiling · Split umschalten |
| `Super+Pfeile` / `Super+H/K/L` | Fokus wechseln |
| `Super+Shift+Pfeile` | Fenster verschieben |
| `Super+1…0` / `Super+Shift+1…0` | Workspace wechseln / Fenster dorthin |
| `Super+Mausrad` | Workspace vor/zurück |
| `Super+Linke/Rechte Maustaste` | Fenster ziehen / Größe ändern |
| `Print` / `Shift+Print` / `Super+Print` | Screenshot Bereich / Vollbild / Fenster |
| Medientasten | Play/Pause, Weiter, Zurück — bevorzugt Spotify, sonst ein anderer laufender Player |
| Lautstärketasten | ±2 % |
| `Super+Shift+Q` | Hyprland beenden |

---

## Besonderheiten

- **Zwischenablage:** Bilder bekommen ein Miniaturbild (Cache: `~/.cache/cliphist-thumbs/`).
  Historie auf 100 Einträge begrenzt (`cliphist/config`), Älteste fallen raus.
  Die Nummern in der Liste sind IDs, keine Positionen — Lücken sind normal.
- **Picture-in-Picture** (Brave/Chromium) öffnet klein und angepinnt unten rechts. Die Regel matcht
  **nur über den Titel**: Das PiP-Fenster hat unter Wayland keine Klasse (`app_id`).
- **Screenshot-Einfrieren** kostet auf NVIDIA beim Auswählen spürbar Bildrate
  (gemessen ~34 statt 240 FPS) — bewusst akzeptiert, Details in `scripts/screenshot.sh`.
- **Sperren** startet hyprlock über Hyprland (`hl.dsp.exec_cmd`), nicht als Kind von wlogout —
  sonst würde das Schließen von wlogout den Sperrvorgang mitreißen.
- **Tastatur-RGB:** `polychromatic-helper --autostart` steht im Autostart, weil Hyprland
  XDG-Autostart (`/etc/xdg/autostart/`) nicht auswertet.
- **xclicker** startet mit `GDK_BACKEND=x11`. Es ist innen ein X11-Programm (liest Tasten per
  XInput2), GTK3 wählt unter Hyprland aber Wayland — dann sieht es keine Tastendrücke und der
  Hotkey lässt sich nicht setzen. Der Hotkey wirkt nur, solange ein **XWayland**-Fenster den
  Fokus hat (z. B. Minecraft), nicht in Wayland-Programmen wie Brave oder kitty.
- **Vencord:** Discord aktualisiert sich selbst nach `~/.config/discord/app-<version>/`. Fehlt
  Vencord nach einem Update, den Installer erneut ausführen — die Einstellungen bleiben.

### Lua-Fallstricke (für spätere Änderungen)

- `hyprctl dispatch` erwartet einen **Lua-Ausdruck**:
  `hyprctl dispatch 'hl.dsp.exec_cmd("befehl")'`. Die alte Form `hyprctl dispatch exec befehl`
  scheitert mit einem Lua-Fehler — das betrifft auch Aufrufe aus anderen Programmen (wlogout, Waybar).
- `hyprctl keyword` funktioniert mit Lua nicht (`keyword can't work with non-legacy parsers. Use eval.`).
- `hyprctl reload` wechselt **nicht** zwischen `.conf` und `.lua` — das Format wird beim Start festgelegt.
- Referenz zur installierten Version: `/usr/share/hypr/hyprland.lua` (Beispiel) und
  `/usr/share/hypr/stubs/hl.meta.lua` (vollständige API).

---

## Gentoo-Hinweise

- **Hyprland ≥ 0.55** prüfen (`emerge -pv gui-wm/hyprland`), ggf. `~amd64` akzeptieren.
- Die Paketnamen oben sind pacman-Namen und weichen unter Gentoo teils ab.
- Die Configs selbst sind distributionsunabhängig. Ausnahme: das Logo in
  `fastfetch/config.jsonc` ist fest auf `"CachyOS"` gesetzt.
