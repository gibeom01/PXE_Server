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

- Redfish API / 원격 접속 설정 (Ansible 연결 준비)
- RAID Controller 펌웨어 업데이트 자동화.
- RAID 구성 (Virtual Disk 생성)
- 가상 미디어(Virtual Media) 마운트 및 OS 부팅 -> OS 설치 및 네트워크 고정 IP 세팅 (Kickstart)

4. 스크립트 실행:

- ansible-playbook [파일 이름]
