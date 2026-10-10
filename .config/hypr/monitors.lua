-- ┌─────────────────────────────────────────────────────────┐
-- │  ⚠ HARDWARE-ABHÄNGIG — auf jedem Rechner anpassen!        │
-- └─────────────────────────────────────────────────────────┘
-- Diese Datei legt Monitore/Auflösung/Skalierung fest.
-- Auf einem anderen Gerät ggf. anpassen:  hyprctl monitors  zeigt Namen/Modi.
--
-- Dieser PC (RTX 3060 Ti): einziger Monitor an DisplayPort, 1440p @ 240 Hz.
-- Connector-Name via DRM/kscreen ermittelt: DP-3
hl.monitor({
    output   = "DP-3",
    mode     = "2560x1440@240",
    position = "0x0",
    scale    = 1,
})

-- Fallback, falls DP-3 mal nicht passt (auskommentiert):
-- hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })
