if is_arch_based; then
  if [[ -n ${OMARCHY_ONLINE_INSTALL:-} ]]; then
    # Install build tools
    sudo pacman -S --needed --noconfirm base-devel

    # Configure pacman
    sudo cp -f ~/.local/share/omarchy/default/pacman/pacman.conf /etc/pacman.conf
    sudo cp -f ~/.local/share/omarchy/default/pacman/mirrorlist /etc/pacman.d/mirrorlist

    # Refresh all repos
    sudo pacman -Syu --noconfirm
  fi
elif is_debian_like; then
  sudo apt-get update

  if [[ -n ${OMARCHY_ONLINE_INSTALL:-} ]]; then
    sudo apt-get install -y build-essential curl git software-properties-common
  fi
else
  echo "Skipping package manager configuration for unsupported OS: ${OMARCHY_OS_ID:-unknown}"
fi
