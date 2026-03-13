# 1. xorriso 패키지 설치
brew install xorriso

# 2. 작업용 디렉토리 생성
mkdir -p ~/iso_build/custom_iso
cd ~/iso_build

# 3. 원본 Rocky Linux (또는 CentOS) ISO 마운트
# (다운로드 폴더에 원본 파일이 있다고 가정합니다)
hdiutil attach ~/Downloads/Rocky-8-x86_64-minimal.iso -mountpoint /Volumes/Rocky8

# 4. 마운트된 ISO의 모든 내용을 작업 폴더로 복사 (숨김 파일 포함)
cp -R /Volumes/Rocky8/* custom_iso/
cp -R /Volumes/Rocky8/.discinfo custom_iso/ 2>/dev/null
cp -R /Volumes/Rocky8/.treeinfo custom_iso/ 2>/dev/null

# 5. 복사가 끝나면 원본 ISO 마운트 해제
hdiutil detach /Volumes/Rocky8
