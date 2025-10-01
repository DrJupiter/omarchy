abort() {
  echo -e "\e[31mOmarchy install requires: $1\e[0m"
  echo
  if gum confirm "Proceed anyway on your own accord and without assistance?"; then
    return 0 2>/dev/null || true
  else
    exit 1
  fi
}

# Must not be running as root
[ "$EUID" -eq 0 ] && abort "Running as root (not user)"

# Must be x86_64
[ "$(uname -m)" != "x86_64" ] && abort "x86_64 CPU"

if is_arch_based; then
  # Must be vanilla Arch (arch-release file present)
  [[ -f /etc/arch-release ]] || abort "Vanilla Arch"

  # Must not be an Arch derivative distro
  for marker in /etc/cachyos-release /etc/eos-release /etc/garuda-release /etc/manjaro-release; do
    [[ -f "$marker" ]] && abort "Vanilla Arch"
  done

  # Must not have Gnome or KDE already installed
  pacman -Qe gnome-shell &>/dev/null && abort "Fresh + Vanilla Arch"
  pacman -Qe plasma-desktop &>/dev/null && abort "Fresh + Vanilla Arch"

elif is_ubuntu; then
  if [[ "${OMARCHY_OS_VERSION_ID:-}" != "24.04" ]]; then
    abort "Ubuntu 24.04 LTS"
  fi
else
  abort "Arch Linux or Ubuntu 24.04 LTS"
fi

# Cleared all guards
echo "Guards: OK"
