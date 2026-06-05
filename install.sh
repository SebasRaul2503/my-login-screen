#!/usr/bin/env bash
#
# install.sh — Copia el tema MatrixRain a /usr/share/sddm/themes/
# No activa el tema (eso se hace aparte, con TTY de respaldo). Ver README.md.
#
set -euo pipefail

SRC="$(cd "$(dirname "$(readlink -f "$0")")" && pwd)/MatrixRain"
DEST="/usr/share/sddm/themes/MatrixRain"

if [[ ! -d "$SRC" ]]; then
    echo "error: no encuentro el tema en $SRC" >&2
    exit 1
fi

echo "Instalando MatrixRain:"
echo "  origen:  $SRC"
echo "  destino: $DEST"
sudo cp -rT "$SRC" "$DEST"
echo
echo "Hecho. Para activarlo, pon en /etc/sddm.conf.d/kde_settings.conf:"
echo "    [Theme]"
echo "    Current=MatrixRain"
echo
echo "Sugerencia: hazlo con una TTY de respaldo abierta (Ctrl+Alt+F2)."
echo "Comando rápido de activación:"
echo "    sudo sed -i 's/^Current=Candy/Current=MatrixRain/' /etc/sddm.conf.d/kde_settings.conf"
