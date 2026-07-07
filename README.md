# dotfiles

Minimalistisches, **monochromes** Hyprland-Setup (dunkel, Graustufen, Terminal-/Hacker-Look).
Arch Linux + Hyprland (Wayland).

![Look](wallpapers/wall.png)

## Enthaltene Konfigurationen

| Ordner | Programm | Zweck |
|---|---|---|
| `hypr/` | Hyprland, hyprlock | Compositor, Keybinds, Sperrbildschirm, Autostart |
| `waybar/` | Waybar | Statusleiste (schwebend, monochrom) |
| `kitty/` | kitty | Terminal |
| `wlogout/` | wlogout | Power-Menü (Sperren/Abmelden/Suspend/Neustart/Herunterfahren) |
| `fuzzel/` | fuzzel | App-Launcher / dmenu |
| `fastfetch/` | fastfetch | Systeminfo |
| `btop/` | btop | Ressourcen-Monitor (Theme `monochrome`) |

---

## Installation

```bash
git clone https://github.com/lokimango/dotfiles.git
cd dotfiles
./install.sh          # kopiert .config/* nach ~/.config (mit Backup) + Wallpaper
```

Danach die **hardwareabhängigen Dateien anpassen** (siehe unten) und neu einloggen.

> `install.sh` legt von vorhandenen Zielordnern automatisch ein Backup unter
> `~/.config-backup-<datum>/` an.

---

## Pakete

### Offiziell (pacman)

```bash
sudo pacman -S --needed \
  hyprland hyprlock hypridle \
  waybar kitty fuzzel fastfetch btop \
  swaync swaybg \
  wl-clipboard cliphist \
  grim slurp \
  brightnessctl playerctl libnotify \
  pipewire-pulse \
  xdg-desktop-portal-hyprland \
  ttf-jetbrains-mono-nerd
```

- **swaync** – Notification-Daemon (im Autostart) · **swaybg** – Wallpaper
- **wl-clipboard + cliphist** – Zwischenablage-Historie (`Super+V`)
- **grim + slurp** – von grimblast für Screenshots benötigt
- **ttf-jetbrains-mono-nerd** – Font inkl. Icons für Waybar/Terminal (zwingend)
- **hypridle** – nur nötig, falls Auto-Sperre gewünscht (hier **nicht** konfiguriert)
- **pipewire-pulse** – liefert `pactl` für die Lautstärke-Keybinds

### AUR (yay/paru)

```bash
yay -S --needed \
  wlogout \
  grimblast-git
```

- **wlogout** – Power-Menü · **grimblast-git** – Screenshot-Wrapper (`Print`-Tasten)

---

## ⚠ Hardwareabhängige Dateien (auf jedem Rechner prüfen/anpassen)

| Datei | Was anpassen |
|---|---|
| `hypr/monitors.conf` | **Monitore, Auflösung, Skalierung.** `hyprctl monitors` zeigt Namen/Modi. Aktuell generisch (`preferred`). |
| `hypr/env.conf` | Cursor-Größe (DPI) und **GPU-spezifische Variablen** – siehe NVIDIA-Hinweis. |
| `hypr/hyprland.conf` | `input { kb_layout = de }` – Tastaturlayout ggf. ändern. |
| **Wallpaper** | Configs erwarten `~/Pictures/wallpapers/wall.png`. `install.sh` kopiert es dorthin. |

### NVIDIA-Hinweis

Dieses Setup läuft auf **Intel** und braucht keine Zusatzvariablen. Auf einem Rechner mit
**NVIDIA-GPU** unter Wayland/Hyprland sonst Flackern/Blackscreen möglich. Dann in
`hypr/env.conf` ergänzen (und aktuelle `nvidia`-Treiber installieren):

```ini
env = LIBVA_DRIVER_NAME,nvidia
env = __GLX_VENDOR_LIBRARY_NAME,nvidia
env = NVD_BACKEND,direct
# ältere Treiber ggf. zusätzlich:
# env = GBM_BACKEND,nvidia-drm
# cursor { no_hardware_cursors = true }  # gegen unsichtbaren/flackernden Cursor
```

Details: <https://wiki.hyprland.org/Nvidia/>

---

## Keybinds (Kurzreferenz)

| Taste | Aktion |
|---|---|
| `Super+Return` | Terminal (kitty) |
| `Super+B` | Firefox |
| `Super+D` | Launcher (fuzzel) |
| `Super+V` | Zwischenablage-Historie |
| `Super+Escape` | Power-Menü (wlogout) → u. a. Sperren |
| `Super+Q` | Fenster schließen · `Super+F` Vollbild · `Super+Shift+F` floaten |
| `Print` / `Shift+Print` / `Super+Print` | Screenshot Bereich / Vollbild / Fenster |

Der Sperrbildschirm läuft über `hypr/scripts/lock.sh` (startet nie doppelt, loggt nach
`~/hyprlock-debug.log`).
