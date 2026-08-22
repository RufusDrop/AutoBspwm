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
echo "No se ejecutará apt upgrade ni se reemplazará la configuración de Kali."
read -r -p "¿Instalar dependencias y elegir un perfil? [S/n] " answer
if [[ ! $answer =~ ^([nN][oO]?|[nN])$ ]]; then
  backup_dir="$HOME/autobspwm-preinstall-$(date +%Y%m%d-%H%M%S)"
  install -d "$backup_dir"
  for name in .zshrc .zsh_history .p10k.zsh; do
    [[ -e "$HOME/$name" ]] && cp -a -- "$HOME/$name" "$backup_dir/"
  done
  if [[ -e "$HOME/.config/autobspwm" ]]; then
    cp -a -- "$HOME/.config/autobspwm" "$backup_dir/"
  fi
  printf 'Copia preventiva creada en: %s\n' "$backup_dir"
  exec ./install.sh
fi
