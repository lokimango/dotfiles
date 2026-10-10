-- ┌─────────────────────────────────────────────────────────┐
-- │  Minimal monochrome Hyprland config                       │
-- │  Look: dark, greyscale, terminal/hacker aesthetic         │
-- └─────────────────────────────────────────────────────────┘
-- Lua-Format (Hyprland >= 0.55). Das alte .conf-Format entfällt mit 0.57.
-- ACHTUNG: Existiert eine hyprland.lua, wird eine daneben liegende
-- hyprland.conf KOMMENTARLOS ignoriert — keine Warnung, kein Logeintrag.

------------------
---- MONITORS ----
------------------
-- ⚠ Hardware-abhängig — ausgelagert
require("monitors")


-------------------------------
---- UMGEBUNGSVARIABLEN    ----
-------------------------------
-- ⚠ Teils hardware-abhängig — ausgelagert
require("env")


---------------------
---- MY PROGRAMS ----
---------------------
local terminal = "kitty"
local menu     = "fuzzel"


-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    -- Wallpaper: swaybg (hyprpaper liest seine Config in dieser Version nicht)
    hl.exec_cmd("swaybg -i " .. os.getenv("HOME") .. "/Pictures/wallpapers/wall.png -m fill")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    -- Clipboard-Historie: wl-paste beobachtet Text + Bilder, cliphist speichert sie
    -- Limit (max. 100, Älteste fliegen raus): ~/.config/cliphist/config -> 'max-items 100'
    hl.exec_cmd("wl-paste --type text  --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Tastatur-RGB (Razer/OpenRazer): stellt den in Polychromatic gespeicherten
    -- Effekt wieder her und startet das Tray-Applet.
    -- Polychromatic liefert dafür /etc/xdg/autostart/polychromatic-autostart.desktop —
    -- aber Hyprland wertet XDG-Autostart NICHT aus (KDE schon). Daher hier von Hand.
    -- Der Helper wartet selbst bis zu 20 s auf den openrazer-Daemon, kein sleep nötig.
    hl.exec_cmd("polychromatic-helper --autostart")
end)


---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout    = "de",
        follow_mouse = 1,
        sensitivity  = -0.45,
        -- Maus-Beschleunigung aus: flache Kurve statt libinput-Default 'adaptive'
        accel_profile = "flat",

        touchpad = {
            natural_scroll       = true,
            disable_while_typing = true,
            tap_to_click         = true,
        },
    },
})

-- Touchpad-Geste: 3 Finger horizontal wischen = Workspace wechseln
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})


-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in     = 3,
        gaps_out    = 6,
        border_size = 1,

        -- Monochrom: aktiver Rand hellgrau, inaktiv fast unsichtbar
        col = {
            active_border   = "rgba(666666ff)",
            inactive_border = "rgba(1e1e1eff)",
        },

        resize_on_border = true,
        layout           = "dwindle",
        allow_tearing    = false,
    },

    decoration = {
        rounding = 6,

        -- Fenster leicht durchscheinend lassen (Terminals regeln Opacity selbst)
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        -- Subtiler Blur, damit das dunkle Wallpaper dezent durchscheint
        blur = {
            enabled           = true,
            size              = 4,
            passes            = 2,
            new_optimizations = true,
            ignore_opacity    = true,
            noise             = 0.02,
            contrast          = 0.9,
            brightness        = 0.8,
            vibrancy          = 0.0,
            vibrancy_darkness = 0.0,
        },

        -- Dezenter, dunkler Schatten – kein bunter Glow
        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 2,
            color        = "rgba(000000aa)",
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        disable_hyprland_logo    = true,
        disable_splash_rendering = true,
        force_default_wallpaper  = 0,
    },
})


--------------------
---- ANIMATIONS ----
--------------------
hl.curve("snappy", { type = "bezier", points = { {0.25, 1}, {0.5, 1} } })

hl.animation({ leaf = "windows",    enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "fade",       enabled = true, speed = 3, bezier = "snappy" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "snappy", style = "slide" })
hl.animation({ leaf = "border",     enabled = true, speed = 4, bezier = "snappy" })

-- Fix (GPU-unabhängig): hyprlock-Lock-Surface beim Entsperren NICHT ausblenden.
-- 'fade' vererbt sonst an fadeLayers->fadeLayersOut und fadet die verschwindende
-- Lock-Surface ~300 ms aus -> sie "blitzt" nach dem Entsperren über dem Desktop nach.
-- (Andere Layer-Fade-INs bleiben erhalten.)
hl.animation({ leaf = "fadeLayersOut", enabled = false, bezier = "snappy" })


---------------
---- RULES ----
---------------
-- Blur hinter Waybar und Launcher
hl.layer_rule({ name = "blur-waybar",   match = { namespace = "^(waybar)$" },           blur = true })
hl.layer_rule({ name = "blur-launcher", match = { namespace = "^(launcher|fuzzel)$" },  blur = true })
hl.layer_rule({ name = "blur-wlogout",  match = { namespace = "^(wlogout)$" },          blur = true })

-- Gängige Dialoge floaten lassen
hl.window_rule({ name = "float-pavucontrol", match = { class = "^(pavucontrol)$" },      float = true })
hl.window_rule({ name = "float-blueman",     match = { class = "^(blueman-manager)$" },  float = true })
hl.window_rule({ name = "float-open-file",   match = { title = "^(Open File)$" },        float = true })

-- Picture-in-Picture (YouTube & Co. in Brave/Chromium).
-- Ohne Regel landet das PiP-Fenster im Tiling und wird bildschirmfuellend gross.
--
-- ACHTUNG beim Matchen: Das Chromium-PiP-Fenster hat unter Wayland eine LEERE
-- Klasse (app_id) — 'class = "^(brave-browser)$"' greift also NICHT.
-- Der Titel lautet exakt "Picture in picture" (Leerzeichen, klein geschrieben),
-- nicht "Picture-in-Picture". Beides per Event-Mitschnitt geprueft, siehe Vault.
-- Die Zeichenklassen fangen zusaetzlich die Schreibweise anderer Browser ab
-- (Firefox: "Picture-in-Picture").
hl.window_rule({
    name  = "pip",
    match = { title = "^[Pp]icture[- ][Ii]n[- ][Pp]icture$" },

    float             = true,
    size              = "640 360",
    -- unten rechts, mit 20 px Abstand zum Rand
    move              = "monitor_w-660 monitor_h-390",
    pin               = true,   -- auf allen Workspaces sichtbar
    keep_aspect_ratio = true,   -- Seitenverhaeltnis beim Ziehen halten
})


---------------------
---- KEYBINDINGS ----
---------------------
local mod = "SUPER"

-- Programme
hl.bind(mod .. " + RETURN", hl.dsp.exec_cmd(terminal))
hl.bind(mod .. " + B",      hl.dsp.exec_cmd("brave"))
-- Toggle: läuft fuzzel schon, wird es beendet — sonst gestartet
hl.bind(mod .. " + D",      hl.dsp.exec_cmd("pkill -x fuzzel || " .. menu))

-- Power-Menü (wlogout): Sperren / Abmelden / Ruhezustand / Neustart / Herunterfahren
hl.bind(mod .. " + ESCAPE", hl.dsp.exec_cmd("pkill wlogout || wlogout -b 5 -p layer-shell"))

hl.bind(mod .. " + Q",         hl.dsp.window.close())
hl.bind(mod .. " + F",         hl.dsp.window.fullscreen())
hl.bind(mod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + P",         hl.dsp.window.pseudo())
hl.bind(mod .. " + J",         hl.dsp.layout("togglesplit"))
hl.bind(mod .. " + SHIFT + Q", hl.dsp.exit())

-- Clipboard-Historie mit Bildvorschau
hl.bind(mod .. " + V", hl.dsp.exec_cmd(os.getenv("HOME") .. "/.config/hypr/scripts/clipboard.sh"))

-- Fokus verschieben (Pfeiltasten + vim hjkl)
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))
hl.bind(mod .. " + H",     hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + L",     hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + K",     hl.dsp.focus({ direction = "up" }))
-- (J ist togglesplit; Fokus nach unten via Pfeil)

-- Fenster verschieben
hl.bind(mod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }))
hl.bind(mod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }))
hl.bind(mod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }))
hl.bind(mod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }))

-- Workspaces 1-10 (10 liegt auf Taste 0)
for i = 1, 10 do
    local key = i % 10
    hl.bind(mod .. " + " .. key,             hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Scroll durch Workspaces
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- Fenster mit Maus bewegen/resizen
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Screenshots (speichern nach ~/Pictures/Screenshots + Zwischenablage + Notification)
local screenshot = os.getenv("HOME") .. "/.config/hypr/scripts/screenshot.sh"
hl.bind("Print",           hl.dsp.exec_cmd(screenshot .. " region"))
hl.bind("SHIFT + Print",   hl.dsp.exec_cmd(screenshot .. " full"))
hl.bind(mod .. " + Print", hl.dsp.exec_cmd(screenshot .. " window"))

-- Lautstärke / Helligkeit (Media-Keys), 2%-Schritte
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +2%"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -2%"),  { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"),                     { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"),                     { locked = true, repeating = true })

-- Medientasten — steuern bevorzugt Spotify über playerctl.
-- '--player=spotify,%any' = erst Spotify, sonst irgendein anderer Player.
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl --player=spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl --player=spotify,%any play-pause"), { locked = true })
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl --player=spotify,%any next"),       { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl --player=spotify,%any previous"),   { locked = true })
