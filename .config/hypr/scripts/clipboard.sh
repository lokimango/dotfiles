#!/usr/bin/env bash
# Zwischenablage-Historie (cliphist + fuzzel) mit Bildvorschau.
#
# cliphist listet Bilder nur als Text:
#   187<TAB>[[ binary data 39 KiB png 355x377 ]]
# Hier wird zusätzlich ein Miniaturbild angehängt, über Rofis erweitertes
# dmenu-Protokoll:  <zeile>\0icon\x1f<pfad>
# (fuzzel unterstützt das; NICHT mit --dmenu0, dort gibt es keine Icons)
#
# Zeile und ID bleiben unverändert -> 'cliphist decode' bekommt exakt das
# Format "<id><TAB>...", das es zwingend braucht.
#
# GRENZEN VON FUZZEL (getestet, nicht änderbar):
#   - Die Icon-Spalte sitzt IMMER ganz links, vor dem Text. Das Bild lässt
#     sich nicht an die Textposition schieben.
#   - Es gibt nur EINE line-height für alle Einträge. Große Bildzeilen neben
#     kleinen Textzeilen sind nicht möglich.
#   - Icon-Größe = line-height. Testweise vergrößern (ohne fuzzel.ini und
#     damit ohne den App-Launcher anzufassen):  fuzzel --dmenu --line-height=40
#
# Nutzt bewusst die normale ~/.config/fuzzel/fuzzel.ini (keine Größenänderung).
set -uo pipefail

# ── Toggle: zweites Super+V schließt den Picker wieder ───────────────────────
# '-x -f' = die GESAMTE Kommandozeile muss exakt "fuzzel --dmenu" sein.
#   -f allein (nur "enthält") wäre gefährlich: es trifft auch jede Shell, in
#   deren Kommandozeile dieser String vorkommt — z. B. den Keybind selbst.
#   Deshalb steht der Toggle hier im Skript und NICHT im Keybind: der Elternteil
#   ist dann 'sh -c .../clipboard.sh' und enthält das Muster nicht.
# Der normale App-Launcher (Super+D) läuft als blankes "fuzzel" ohne Argumente
# und wird von diesem Muster nicht getroffen.
if pkill -x -f 'fuzzel --dmenu'; then
    exit 0
fi

CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/cliphist-thumbs"
mkdir -p "$CACHE"

# Miniaturbilder aufräumen, die 7 Tage nicht mehr benutzt wurden
find "$CACHE" -type f -atime +7 -delete 2>/dev/null

build_list() {
    cliphist list | while IFS= read -r line; do
        if [[ "$line" == *"binary data"* ]] \
        && [[ "$line" =~ (png|jpg|jpeg|bmp|webp|gif) ]]; then

            key=$(printf '%s' "$line" | md5sum | cut -c1-16)
            thumb="$CACHE/$key.png"

            if [ ! -s "$thumb" ]; then
                cliphist decode <<< "$line" \
                    | magick - -thumbnail 128x128 "$thumb" 2>/dev/null
            fi

            if [ -s "$thumb" ]; then
                printf '%s\0icon\x1f%s\n' "$line" "$thumb"
                continue
            fi
        fi
        printf '%s\n' "$line"
    done
}

sel=$(build_list | fuzzel --dmenu)
[ -n "$sel" ] && printf '%s' "$sel" | cliphist decode | wl-copy
