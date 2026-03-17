주로 사용하는 서버

DELL R620, R630, R640

RENOVO SR630

HPE Gen9, Gen10, Gen11

IBM System x3550 M4
- 구형 IBM 장비는 IMM2 (Integrated Management Module II) 칩셋 사용.
- Mac에서 IBM IMM2와 통신하려면 ipmitool이 추가로 필요.
- brew install ipmitool
- ansible-galaxy collection install community.general
- 파일은 deploy_os.yml, windows_config.yml만 가능함.

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
