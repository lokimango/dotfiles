#!/bin/sh
# Sperrt den Bildschirm mit hyprlock.
# - startet nie eine zweite Instanz (verhindert "lockscreen app died")
# - loggt ausführlich nach ~/hyprlock-debug.log, damit ein Absturz
#   nachvollziehbar ist, ohne dass man live zuschauen muss.

if pidof hyprlock >/dev/null 2>&1; then
    exit 0            # läuft bereits -> nichts tun
fi

LOG="$HOME/hyprlock-debug.log"
{
    echo "==================================================="
    echo "lock gestartet: $(date '+%Y-%m-%d %H:%M:%S')"
    echo "hyprlock: $(hyprlock --version 2>&1 | head -1)"
    echo "==================================================="
} >> "$LOG"

# exec -> ein einziger, sauberer Prozess (kein verwaister Elternprozess)
exec hyprlock --verbose >> "$LOG" 2>&1
