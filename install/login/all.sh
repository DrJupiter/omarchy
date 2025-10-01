if is_arch_based; then
  run_logged $OMARCHY_INSTALL/login/plymouth.sh
  run_logged $OMARCHY_INSTALL/login/limine-snapper.sh
  run_logged $OMARCHY_INSTALL/login/enable-mkinitcpio.sh
  run_logged $OMARCHY_INSTALL/login/alt-bootloaders.sh
else
  echo "Skipping bootloader and Plymouth configuration on ${OMARCHY_OS_ID:-unknown}"
fi
