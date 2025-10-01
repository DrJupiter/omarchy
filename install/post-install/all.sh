if is_arch_based; then
  run_logged $OMARCHY_INSTALL/post-install/pacman.sh
fi
source $OMARCHY_INSTALL/post-install/finished.sh
