#!/bin/bash

set -o pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
# shellcheck source=bin/lib/os.sh
source "$script_dir/os.sh"

if [[ -z ${OMARCHY_PKG_MANAGER:-} ]]; then
  if command -v pacman >/dev/null 2>&1; then
    OMARCHY_PKG_MANAGER="pacman"
  elif command -v apt-get >/dev/null 2>&1; then
    OMARCHY_PKG_MANAGER="apt"
  else
    OMARCHY_PKG_MANAGER=""
  fi
fi

pkg_manager() {
  if [[ -n ${OMARCHY_PKG_MANAGER:-} ]]; then
    echo "$OMARCHY_PKG_MANAGER"
    return 0
  fi
  return 1
}

pkg_manager_is() {
  local current
  current=$(pkg_manager 2>/dev/null) || return 1
  [[ $current == "$1" ]]
}

pkg_install() {
  local mgr
  mgr=$(pkg_manager) || {
    echo "Package manager not supported on this system." >&2
    return 1
  }

  case "$mgr" in
  pacman)
    sudo pacman -S --noconfirm --needed "$@"
    ;;
  apt)
    sudo apt-get install -y "$@"
    ;;
  esac
}

pkg_remove() {
  local mgr
  mgr=$(pkg_manager) || {
    echo "Package manager not supported on this system." >&2
    return 1
  }

  case "$mgr" in
  pacman)
    sudo pacman -Rns --noconfirm "$@"
    ;;
  apt)
    sudo apt-get purge -y "$@"
    sudo apt-get autoremove -y
    ;;
  esac
}

pkg_is_installed() {
  local mgr pkg
  pkg="$1"
  [[ -n $pkg ]] || return 1
  mgr=$(pkg_manager) || return 1

  case "$mgr" in
  pacman)
    pacman -Q "$pkg" &>/dev/null
    ;;
  apt)
    dpkg -s "$pkg" &>/dev/null
    ;;
  esac
}

pkg_available_list() {
  local mgr
  mgr=$(pkg_manager) || return 1
  case "$mgr" in
  pacman)
    pacman -Slq
    ;;
  apt)
    apt-cache pkgnames 2>/dev/null | sort -fu
    ;;
  esac
}

pkg_installed_list() {
  local mgr
  mgr=$(pkg_manager) || return 1
  case "$mgr" in
  pacman)
    if command -v yay >/dev/null 2>&1; then
      yay -Qqe
    else
      pacman -Qq
    fi
    ;;
  apt)
    dpkg-query -W -f='${binary:Package}\n' | sort -fu
    ;;
  esac
}

pkg_available_preview_command() {
  local mgr
  mgr=$(pkg_manager) || return 1
  case "$mgr" in
  pacman)
    echo "pacman -Sii {1}"
    ;;
  apt)
    echo "apt-cache show {1}"
    ;;
  esac
}

pkg_installed_preview_command() {
  local mgr
  mgr=$(pkg_manager) || return 1
  case "$mgr" in
  pacman)
    if command -v yay >/dev/null 2>&1; then
      echo "yay -Qi {1}"
    else
      echo "pacman -Qi {1}"
    fi
    ;;
  apt)
    echo "apt-cache policy {1}"
    ;;
  esac
}

pkg_supports_aur() {
  pkg_manager_is pacman && command -v yay >/dev/null 2>&1
}
