MAC Air 기준

# 1. 물리적 연결 준비:

- 랜 케이블(UTP): Cat5e, Cat6.
- 케이블 랜선 젠더(Type-C to RJ45): Belkin, Anker 제품. 

# 2-1. 전면 LCD 패널을 이용한 iDRAC IP 설정

1. 메뉴 진입: LCD 화면에 'Ready' 또는 서버 이름이 떠 있다면, [OK] 버튼을 눌러 주 메뉴로 들어갑니다.

2. View 선택: [▶] 버튼을 눌러 [Setup] 메뉴를 찾은 뒤 [OK]를 누릅니다. (모델에 따라 View -> iDRAC 순서인 경우도 있습니다.)

3. iDRAC 메뉴 찾기: [Setup] 안에서 [iDRAC] 메뉴가 나올 때까지 화살표를 누르고 [OK]를 선택합니다.

4. IP 설정 방식 변경 (DHCP -> Static):
- IPv4 -> Enable -> Yes 확인
- DHCP 항목에서 [No] 또는 [Static]을 선택합니다. (고정 IP를 쓰기 위함)

5. IP 주소 입력:
- IP 메뉴에서 [OK]를 누르면 첫 번째 자리 숫자가 깜빡입니다. 화살표로 숫자를 조정하고 [OK]를 눌러 다음 칸으로 넘어갑니다.
- 예: 192.168.000.120 형태로 입력합니다.

6. 서브넷 마스크 및 게이트웨이: 같은 방식으로 Subnet(255.255.255.0)과 Gateway(192.168.0.1)를 입력합니다.

7. 저장 및 적용: 모든 입력이 끝나면 [Set] 또는 [Apply] 메뉴에서 [Yes]를 눌러 저장합니다. 약 10~30초 후 설정이 반영됩니다.

# 2-2. 전면 iDRAC(톱니모양 - 관리 전용) 포트 연결

1. R640, R630 경우 C 타입으로 MAC 연결 후 접속.

2. 전면 포트 연결 시: 대역은 169.254.0.3/25 (Mac IP: 169.254.0.4/25)

#### * LCD 패널이 없거나 전면 포트 없는 구형 모델의 경우 -> BIOS(System Setup) 진입해 수동으로 대역 설정 (가장 확실함) *

# 3. Mac 네트워크 대역 설정 (초기 접속용):

- Dell 서버(iDRAC 초기 IP: 192.168.0.120) 기준 Mac에 래선 젠더 꽂고 랜 케이블 -> 서버 뒷면 iDRAC 전용 포트(스패너 모양) 연결.
- Mac(애플 메뉴) -> 시스템 설정(System Settings) -> 네트워크(Network)
- [세부사항...] 버튼 클릭 -> [TCP/IP] 탭 이동.
- 'IPv4 구성'을 'DHCP 서버를 사용하여' -> '수동(Manually)' 변경.
- Addr(192.168.0.100), Sub(255.255.255.0), gw(X) 입력 -> 저장.
- 브라우저 "https://192.168.0.120" 접속 -> 초기 계정(root/calvin 또는 태그 비밀번호) 로그인 확인.

# 4. Disk 추가, 삭제 방법:

- configur_raid.yml 파일 drives 목록 항목 추가, 삭제. (SSD, HDD 같이 사용 시 되도록 SSD를 0,1 처럼 앞쪽 베이에 OS용도로 사용 구성 추천)
- 예시 
drives:
    - "Disk.Bay.0:Enclosure.Internal.0-1:{{ controller_fqdd }}"
    - "Disk.Bay.1:Enclosure.Internal.0-1:{{ controller_fqdd }}"
    - "Disk.Bay.2:Enclosure.Internal.0-1:{{ controller_fqdd }}" # 추가된 디스크

# 5. RAID 레벨 변경방법: 

- configur_raid.yml 파일 내 코드 변수 값 수정.
- RAID 0 구성 시는 volume_type: "Stripe" (또는 "RAID 0"), 조건 drives 목록 최소 1개 이상.
- RAID 5 구성 시는 volume_type: "Parity" (또는 "RAID 5"), 조건 drives 목록에 최소 3개 이상의 디스크 기재.

# 6. 파일 실행 준비:

- OS 미설치 시에는 main.tf, terraform.tfvars 파일 주석 처리 해야함 (main.tf는 locals 전부, 1번 전부, 2번 depends_on, 2-3번 전부, 3, 4번 전부, terraform.tfvars는 os_type, iso_name 주석처리)
- Ubuntu만 make_linux_iso.sh 파일에 password: 구문에 넣을 암호를 Mac 터미널에서 출력한 암호 복붙하고 실행. (명령어: openssl passwd -6 "원하는 PW로")
- ISO 폴더에 .iso 넣고 진행.
- 폴더를 ~/Desktop/ 위치에 옮겨 진행.
- terraform.tfvars 파일에 사용할 raid만 남겨두고 주석처리 후 진행.
- 터미널에서 먼저 scripts 파일에 이동해 인프라 배포에 필요한 커스텀 iso 파일을 수동으로 생성. -> 다시 돌아가서 전부 동작.
- 예시
###### Windows ISO 생성
./make_win_iso.sh

###### Rocky Linux ISO 생성
./make_linux_iso.sh rocky

###### Ubuntu ISO 생성
./make_linux_iso.sh ubuntu

# 7. Terraform 고려 사항:

- HTTP 웹 서버의 늪: 3단계(OS 배포)에서 python3 -m http.server를 실행하면 터미널이 멈춰서 다음 작업으로 넘어가지 않습니다.
👉 해결: Terraform 내에서 웹 서버를 백그라운드로 몰래 띄우고, Ansible이 iDRAC에 ISO를 마운트시키고 나면 웹 서버를 자동으로 종료(Kill)하도록 쉘 스크립팅을 혼합합니다.

- Windows 설치 대기 시간: 서버가 재부팅되고 Windows가 설치되는 데에는 물리적으로 약 20~30분이 소요됩니다. 4번 Playbook이 곧바로 실행되면 접속 실패(WinRM Not Found)가 발생합니다.
👉 해결: OS 설치가 끝날 때까지 Terraform이 충분히 대기(sleep)하도록 타임아웃을 설정합니다.

# 8. 문법 검증 방법

- 문법 검증 (Syntax Check) -> ansible-playbook linux_config.yml --syntax-check -i inventory.ini
- 가상 실행 (Dry-run / Check Mode) -> ansible-playbook linux_config.yml --check -i inventory.ini
- 변경점 상세 비교 (Diff Mode) -> ansible-playbook linux_config.yml --check --diff -i inventory.ini

# 9. Terraform 배포 방법:

- (Ansible로 1개씩 테스트 후 진행)

- python3 -m http.server 8000 (자동화 수행 시 명령어를 실행한 채로 두는 것이 필수적 -> 다른 터미널 창 열고 나머지 수행)
- terraform init                                                                        ->(초기화 및 Terraform 플러그인을 다운로드)
- terraform validate                                                                    -> (문법 에러 체크)
- terraform plan                                                                        -> (실행 계획 출력)
- terraform apply -auto-approve                                                         -> (실행 계획 먼저 보여주고 적용 여부 묻는 입력 모드 활성화)
- terraform apply -replace='null_resource.hardware_provisioning["idc-node-01"]'         -> (["idc-node-03"]' (OS 설정 실패 시 한 줄로 딱 그 서버만 다시 세팅할 수 있음.))

# 10. Disk 주의사항

- 이종 미디어 혼합 금지 (SSD + HDD): 하나의 RAID 볼륨(예: OS_RAID1) 안에 SSD와 HDD를 섞어서 묶을 수 없습니다. (RAID 컨트롤러가 거부합니다.)

- 이종 인터페이스 혼합 금지 (SATA + SAS): 하나의 RAID 볼륨 안에 SATA 방식 디스크와 SAS 방식 디스크를 섞을 수 없습니다.

- 용량 낭비 주의: 코드는 선택한 디스크들의 '최대 가용 용량'을 자동으로 끌어다 씁니다. 만약 1TB 디스크와 2TB 디스크를 RAID 1(미러링)으로 묶는다고 코드에 적으면, 묶이기는 하지만 작은 용량(1TB)을 기준으로 동기화되므로 2TB 디스크의 절반(1TB)은 영구적으로 버려지게 됩니다. 가급적 동일 용량의 디스크를 슬롯에 꽂아주세요.

- 왼쪽 상단부터 오른쪽으로 0번부터 시작하여 번호가 매겨짐.
