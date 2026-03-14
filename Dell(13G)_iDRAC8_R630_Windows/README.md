MAC Air 기준

1. 물리적 연결 준비:

- 랜 케이블(UTP): Cat5e, Cat6.
- 케이블 랜선 젠더(Type-C to RJ45): Belkin, Anker 제품. 

2. Mac 네트워크 대역 설정 (초기 접속용):

- Dell 서버(iDRAC 초기 IP: 192.168.0.120) 기준 Mac에 래선 젠더 꽂고 랜 케이블 -> 서버 뒷면 iDRAC 전용 포트(스패너 모양) 연결.
- Mac(애플 메뉴) -> 시스템 설정(System Settings) -> 네트워크(Network)
- [세부사항...] 버튼 클릭 -> [TCP/IP] 탭 이동.
- 'IPv4 구성'을 'DHCP 서버를 사용하여' -> '수동(Manually)' 변경.
- Addr(192.168.0.100), Sub(255.255.255.0), gw(X) 입력 -> 저장.
- 브라우저 "https://192.168.0.120" 접속 -> 초기 계정(root/calvin 또는 태그 비밀번호) 로그인 확인.

3. 전체 자동화 파이프라인 구성 방법:

- 1단계: 자동화 환경 준비 (Mac Air)                    -> Dell iDRAC 제어할 Ansible 모듈과 Redfish API 통신 필요할 Python 라이브러리 설치.
- 2단계: 하드웨어 펌웨어 최적화 (iDRAC)                  -> 서버의 iDRAC 관리 포트(IP: 10.10.10.120)로 접속해 펌웨어 설치 파일 업로드.
- 3단계: 물리 디스크 RAID 및 스토리지 구성 (iDRAC)        -> 디스크 설정 밀고, 전면 베이 꽂힌 1.2TB 디스크 2개 묶어 RAID 1(미러링) 볼륨 생성.
- 4단계: Windows OS 무인 설치 (iDRAC & 가상 미디어)     -> HTTP 서버 통해, 무인 설치 응답 파일 포함된 Windows Server ISO iDRAC의 가상 CD-ROM 마운트.
- 5단계: OS 내부 환경 및 보안 설정 (Windows WinRM)      -> Ansible은 이제 Windows OS 내부 직접 원격 접속(WinRM)하여 계정 보안, 네트워크 셋팅, RDP 포트변경, firewall 개방, 원격 접속 허용.

4. 스크립트 실행방법:

- ansible-playbook [파일 이름]

5. 파일 싫행순서:

ISO 폴더에 Windows_Server_2019.iso 넣고 진행.
실행 위치: ~/Desktop/Dell(13G)_iDRAC8_R630_Windows 위치에서 진행.

- setting.sh                                        -> MAC 터미널에서 1섹션씪 진행.
- update_firmware.yml                               -> ansible-playbook [파일 이름]으로 한번에 진행.
- configure_raid.yml                                -> ansible-playbook [파일 이름]으로 한번에 진행.
- make_iso.sh                                       -> MAC 터미널에서 1섹션씩 진행.
- cd ~/Desktop/Dell(14G,15G,16G)_iDRAC9_R640/ISO    -> MAC 터미널 복사 후 붙여넣기 진행. (파일이 생성된 경로 이동.)
- python3 -m http.server 8000                       -> MAC 터미널 복사 후 붙여넣기 진행. (iDRAC 접속할 수 있도록 웹서버 오픈.)
- deploy_os.yml                                     -> ansible-playbook [파일 이름]으로 한번에 진행.
- pip3 install "pywinrm>=0.3.0"                     -> MAC 터미널 복사 후 붙여넣기 진행. (Ansible Windows 접속용 Python 라이브러리 설치.)
- windows_config.yml                                -> ansible-playbook -i inventory.ini [파일 이름]으로 한번에 진행.
