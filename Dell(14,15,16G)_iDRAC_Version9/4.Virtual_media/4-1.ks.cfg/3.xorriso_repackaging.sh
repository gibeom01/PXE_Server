cd ~/iso_build

xorriso -as mkisofs \
  -R -J -v -T \
  -V "CUSTOM_ISO" \
  -b isolinux/isolinux.bin \
  -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e images/efiboot.img \
  -no-emul-boot \
  -o rocky8_custom_ks.iso \
  custom_iso/

# 참고: -V "CUSTOM_ISO" 부분이 앞서 grub.cfg에서 설정한 라벨명과 일치해야 합니다.
