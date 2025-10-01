# Install all base packages
packages_file="$OMARCHY_INSTALL/omarchy-base.packages"

if [[ -n ${OMARCHY_OS_ID:-} ]]; then
  if [[ -f "$OMARCHY_INSTALL/omarchy-base.packages.${OMARCHY_OS_ID}" ]]; then
    packages_file="$OMARCHY_INSTALL/omarchy-base.packages.${OMARCHY_OS_ID}"
  elif is_debian_like && [[ -f "$OMARCHY_INSTALL/omarchy-base.packages.debian" ]]; then
    packages_file="$OMARCHY_INSTALL/omarchy-base.packages.debian"
  fi
fi

mapfile -t packages < <(grep -v '^#' "$packages_file" | grep -v '^$')

if is_arch_based; then
  sudo pacman -S --noconfirm --needed "${packages[@]}"
elif is_debian_like; then
  if ((${#packages[@]})); then
    installable=()
    skipped=()

    for pkg in "${packages[@]}"; do
      if apt-cache show "$pkg" >/dev/null 2>&1; then
        installable+=("$pkg")
      else
        skipped+=("$pkg")
      fi
    done

    if ((${#installable[@]})); then
      sudo apt-get install -y "${installable[@]}"
    fi

    if ((${#skipped[@]})); then
      echo "Skipped packages not available via apt: ${skipped[*]}"
    fi
  fi
else
  echo "Package installation is not implemented for ${OMARCHY_OS_ID:-unknown}"
fi
