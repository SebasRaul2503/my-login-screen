#!/usr/bin/env bash
#
# install.sh — Copia el tema Aurora a /usr/share/sddm/themes/
# No activa el tema (eso se hace aparte, con TTY de respaldo). Ver README.md.
#
set -euo pipefail

SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)/Aurora"
DEST="/usr/share/sddm/themes/Aurora"

if [[ ! -d "$SRC" ]]; then
    echo "error: no encuentro el tema en $SRC" >&2
    exit 1
fi

echo "Instalando Aurora:"
echo "  origen:  $SRC"
echo "  destino: $DEST"
sudo cp -rT "$SRC" "$DEST"
echo
echo "Hecho. Para activarlo, pon en /etc/sddm.conf.d/kde_settings.conf:"
echo "    [Theme]"
echo "    Current=Aurora"
echo
echo "Sugerencia: hazlo con una TTY de respaldo abierta (Ctrl+Alt+F2)."
echo "Comando rápido de activación:"
echo "    sudo sed -i 's/^Current=.*/Current=Aurora/' /etc/sddm.conf.d/kde_settings.conf"
