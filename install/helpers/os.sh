# Detect operating system information for Omarchy scripts
if [ -r /etc/os-release ]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  export OMARCHY_OS_ID="${ID:-}"
  export OMARCHY_OS_VERSION_ID="${VERSION_ID:-}"
  export OMARCHY_OS_ID_LIKE="${ID_LIKE:-}"
else
  export OMARCHY_OS_ID=""
  export OMARCHY_OS_VERSION_ID=""
  export OMARCHY_OS_ID_LIKE=""
fi

is_arch_based() {
  [[ "${OMARCHY_OS_ID:-}" == "arch" ]]
}

is_debian_like() {
  [[ " ${OMARCHY_OS_ID_LIKE:-} " == *" debian "* ]] || [[ "${OMARCHY_OS_ID:-}" == "debian" ]] || [[ "${OMARCHY_OS_ID:-}" == "ubuntu" ]]
}

is_ubuntu() {
  [[ "${OMARCHY_OS_ID:-}" == "ubuntu" ]]
}
