주로 사용하는 서버

DELL R620, R630, R640

HPE Gen9, Gen10, Gen11

RENOVO SR630

IBM System x3550 M4
- 구형 IBM 장비는 IMM2 (Integrated Management Module II) 칩셋 사용.
- Mac에서 IBM IMM2와 통신하려면 ipmitool이 추가로 필요.
- brew install ipmitool
- ansible-galaxy collection install community.general
- 파일은 deploy_os.yml, windows_config.yml만 가능함.

XCC, IMM2 통합 관리 방법 (LXCA 활용)
LXCA 설치: 윈도우나 리눅스 PC가 아닌, VMware나 Hyper-V 같은 가상화 서버 위에 LXCA 이미지(Virtual Appliance)를 설치합니다.
노드 등록 (Discovery): LXCA 관리 화면에서 SR630의 XCC IP와 x3550 M4의 IMM2 IP를 각각 등록합니다.
대시보드 확인: 등록이 완료되면 한 화면에서 두 서버의 전원 상태, 온도, 팬 속도, 하드웨어 에러 로그를 동시에 모니터링할 수 있습니다.
주의사항 및 차이점
기능의 차이: 최신 SR630(XCC)은 펌웨어 업데이트나 OS 배포까지 원격으로 가능하지만, 구형 x3550 M4(IMM2)는 모델에 따라 단순 모니터링이나 전원 제어 정도로 기능이 제한될 수 있습니다.
라이선스: 단순 모니터링은 무료인 경우가 많지만, 서버 설정값 복제나 고급 자동화 기능을 쓰려면 서버 대수만큼 라이선스가 필요할 수 있습니다.

Inspur(중국)

Huawei(중국)

Supermicro

Cisco

---

1. terraform.tfvars, for_each 파일 작성.
2. 서버별 코드 통일. (Renove/IBM, Inspur(중국), Huawei(중국), Supermicro, cisco)
3. 분리한 서버별에서 OS별로 분리. (Linux, Windows)

---
개념

- Apache (웹 서버: 브라우저 요청 받아 HTML/Image 등 전송하는 역할)
- PHP (서버 스크립트 언어: 서버에서 동작, 데이터베이스 조회나 로직 처리 후 HTML 생성 역할)

설치 방법

(Linux - Ubuntu 기반)
- sudo apt update && sudo apt upgrade (패키지 업데이트)
- sudo apt install apache2 (Apache 설치)
- sudo apt install php libaoache2-mod-php (PHP 설치)
- systemctl status apache2 (설정 확인)

(Windows 기반)
- PHP 공식 사이트 -> "Thread Safe' ZIP 파일 다운 -> C:\php 등에 압축 해제 (설치파일 다운)
- https.conf 파일 -> PHP 모듈 설정 연결 (Apache 연동)
- XAMPP, WAMP 등 올인원 패키지 사용해 Apache, PHP, MySQL 동시 설치 가능 (간편 설치)
