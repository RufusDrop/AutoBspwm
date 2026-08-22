#!/usr/bin/env bash
# AutoBspwm launcher for current Kali Linux releases.
set -Eeuo pipefail

if [[ ${EUID} -eq 0 ]]; then
  echo "Ejecuta este script con tu usuario normal, no como root ni con sudo." >&2
  exit 1
fi

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
cd "$repo_dir"

echo "AutoBspwm para Kali Linux (instalación segura)"
echo "No se ejecutará apt upgrade ni se compilará software desde Git."
read -r -p "¿Instalar dependencias y elegir un perfil? [S/n] " answer
if [[ ! $answer =~ ^([nN][oO]?|[nN])$ ]]; then
  exec ./install.sh
fi
