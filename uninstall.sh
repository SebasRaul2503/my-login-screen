#!/usr/bin/env bash
#
# uninstall.sh — Revierte el login al tema Candy y borra Outrun de /usr/share.
# Úsalo desde una TTY de respaldo si algo sale mal.
#
set -euo pipefail

CONF="/etc/sddm.conf.d/kde_settings.conf"
DEST="/usr/share/sddm/themes/Outrun"

echo "Revirtiendo el tema activo a Candy en $CONF ..."
sudo sed -i 's/^Current=Outrun/Current=Candy/' "$CONF"
grep '^Current=' "$CONF" || true

echo "Eliminando $DEST ..."
sudo rm -rf "$DEST"

echo
echo "Listo. Reinicia SDDM para aplicar (desde una TTY):"
echo "    sudo systemctl restart sddm"
