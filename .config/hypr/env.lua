-- ┌─────────────────────────────────────────────────────────┐
-- │  ⚠ Teils HARDWARE-ABHÄNGIG (HiDPI, GPU) — prüfen          │
-- └─────────────────────────────────────────────────────────┘
-- Umgebungsvariablen. Cursor-Größe ggf. an DPI des Geräts anpassen.

-- Mauszeiger: KDE "Breeze Dark" (Paket breeze-cursors; Ordnername breeze_cursors).
-- Ohne diese Zeile fällt Hyprland auf /usr/share/icons/default zurück -> Adwaita.
-- Breeze ist ein reines XCursor-Theme (kein hyprcursor) -> XCURSOR_THEME genügt.
-- Gilt für Hyprland selbst und alle daraus gestarteten Programme (auch XWayland,
-- z. B. Minecraft). gsettings zieht Hyprland per cursor:sync_gsettings_theme
-- (Default: an) automatisch mit, für GTK-Programme.
hl.env("XCURSOR_THEME", "breeze_cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ┌─────────────────────────────────────────────────────────┐
-- │  NVIDIA (RTX 3060 Ti) — Wayland-Variablen AN             │
-- │  Auf dem Laptop (Intel) waren die AUS; hier zwingend an.  │
-- └─────────────────────────────────────────────────────────┘
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")
hl.env("NVD_BACKEND", "direct")

-- AQ_DRM_DEVICES nur bei Multi-GPU nötig (z. B. iGPU + dGPU). Dieser PC hat
-- nur die Nvidia-Karte, daher NICHT gesetzt. Bei Bedarf:
-- hl.env("AQ_DRM_DEVICES", "/dev/dri/card1")

-- Gegen flackernden/unsichtbaren Mauszeiger auf Nvidia. Falls der Cursor sauber
-- läuft, kann das wieder raus (Software-Cursor kostet minimal Leistung).
hl.config({
    cursor = {
        no_hardware_cursors = true,
    },
})
