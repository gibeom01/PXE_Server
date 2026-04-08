#!/bin/bash

# 사용법: ./make_linux_iso.sh [rocky|ubuntu]
OS_TYPE=$1
BASE_DIR="../ISO"
WORK_DIR="/tmp/linux_custom_build"

if [ -z "$OS_TYPE" ]; then
  echo "사용법: $0 [rocky|ubuntu]"
  exit 1
fi

echo "1. 작업용 디렉토리를 초기화합니다..."
mkdir -p "$WORK_DIR"
rm -rf "${WORK_DIR:?}"/*

if [ "$OS_TYPE" == "rocky" ]; then
    echo "=== [Rocky Linux/CentOS ISO 리패키징 시작] ==="
    ORIGINAL_ISO="$BASE_DIR/Rocky-8.iso" # 준비하신 원본 ISO 이름으로 변경하세요
    CUSTOM_ISO="$BASE_DIR/Rocky-8-Auto.iso"
    
    echo "2. 원본 ISO 마운트 및 복사..."
    hdiutil attach "$ORIGINAL_ISO" -mountpoint /Volumes/Rocky_ISO -noverify -nobrowse
    cp -R /Volumes/Rocky_ISO/* "$WORK_DIR/"
    hdiutil detach /Volumes/Rocky_ISO
    
    echo "3. ks.cfg 삽입..."
    cat << 'EOF' > "$WORK_DIR/ks.cfg"
# Install OS instead of upgrade
install
cdrom
text
# 방금 만든 물리 디스크(RAID 볼륨)의 모든 파티션 묻지 않고 자동 포맷
clearpart --all --initlabel
autopart --type=lvm
# 기본 계정 설정 (Root 비밀번호: LinuxP@ss123!)
rootpw --plaintext LinuxP@ss123!
timezone Asia/Seoul
reboot
EOF
    
    echo "4. 부트로더(GRUB/ISOLINUX) 수정 (ks.cfg 자동 인식)..."
    # Mac용 sed는 -i 옵션 뒤에 백업 확장자('')를 명시해야 합니다.
    sed -i '' 's/inst.stage2/inst.ks=cdrom:\/ks.cfg inst.stage2/g' "$WORK_DIR/isolinux/isolinux.cfg"
    sed -i '' 's/inst.stage2/inst.ks=cdrom:\/ks.cfg inst.stage2/g' "$WORK_DIR/EFI/BOOT/grub.cfg"

elif [ "$OS_TYPE" == "ubuntu" ]; then
    echo "=== [Ubuntu Server ISO 리패키징 시작] ==="
    ORIGINAL_ISO="$BASE_DIR/Ubuntu-22.04.iso" # 준비하신 원본 ISO 이름으로 변경하세요
    CUSTOM_ISO="$BASE_DIR/Ubuntu-22.04-Auto.iso"
    
    echo "2. 원본 ISO 마운트 및 복사..."
    hdiutil attach "$ORIGINAL_ISO" -mountpoint /Volumes/Ubuntu_ISO -noverify -nobrowse
    cp -R /Volumes/Ubuntu_ISO/* "$WORK_DIR/"
    hdiutil detach /Volumes/Ubuntu_ISO
    
    echo "3. nocloud 디렉토리 생성 및 user-data, meta-data 삽입..."
    mkdir -p "$WORK_DIR/nocloud"

    # meta-data는 빈 파일이어도 무방합니다.
    touch "$WORK_DIR/nocloud/meta-data"

    # user-data (Autoinstall) 동적 생성
    cat << 'EOF' > "$WORK_DIR/nocloud/user-data"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: linux-server
    # Root 비밀번호 설정
    password: "$6$ex.UUGBNYsUP$2... (여기에 터미널에서 나온 긴 문자열 붙여넣기)"
    username: root
  storage:
    layout:
      name: lvm
      match:
        size: largest  # 가장 큰 디스크(RAID 볼륨)를 찾아 묻지 않고 자동 포맷
EOF
    
    echo "4. 부트로더(GRUB) 수정 (Autoinstall 자동 인식)..."
    sed -i '' 's/---/autoinstall ds=nocloud;s=\/cdrom\/nocloud\/ ---/g' "$WORK_DIR/boot/grub/grub.cfg"
    sed -i '' 's/---/autoinstall ds=nocloud;s=\/cdrom\/nocloud\/ ---/g' "$WORK_DIR/boot/grub/loopback.cfg"

else
    echo "지원하지 않는 OS 타입입니다 (rocky 또는 ubuntu를 입력하세요)."
    exit 1
fi

echo "5. 커스텀 ISO 파일 생성 중..."
# Linux ISO에 범용적으로 적용되는 xorriso 옵션
xorriso -as mkisofs \
  -r -V "CUSTOM_LINUX_AUTO" \
  -J -joliet-long -b isolinux/isolinux.bin \
  -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e images/efiboot.img -no-emul-boot \
  -o "$CUSTOM_ISO" "$WORK_DIR"

echo "🎉 작업 완료! $CUSTOM_ISO 파일이 성공적으로 만들어졌습니다."
