#!/bin/bash

# Basic operating system detection helpers for Omarchy runtime scripts.
if [[ -z ${OMARCHY_OS_ID:-} ]] && [[ -r /etc/os-release ]]; then
  # shellcheck disable=SC1091
  . /etc/os-release
  OMARCHY_OS_ID="${ID:-}"
  OMARCHY_OS_VERSION_ID="${VERSION_ID:-}"
  OMARCHY_OS_ID_LIKE="${ID_LIKE:-}"
fi

is_arch_based() {
  [[ ${OMARCHY_OS_ID:-} == "arch" ]] || [[ " ${OMARCHY_OS_ID_LIKE:-} " == *" arch "* ]]
}

is_debian_like() {
  [[ " ${OMARCHY_OS_ID_LIKE:-} " == *" debian "* ]] || [[ ${OMARCHY_OS_ID:-} == "debian" ]] || [[ ${OMARCHY_OS_ID:-} == "ubuntu" ]]
}

is_ubuntu() {
  [[ ${OMARCHY_OS_ID:-} == "ubuntu" ]]
}
