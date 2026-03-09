PXE 서버 구축용 Ansible role을 Rocky Linux 8 기준으로 구성하면 DHCP(TFTP 내장 dnsmasq), TFTP, Nginx(HTTP/Kickstart 제공)를 한 번에 자동화할 수 있습니다. GitHub 오픈소스 role(bertvv/pxeserver, shomatan/pxe-server-kickstart)을 기반으로 실무에 맞게 커스터마이징한 예제입니다.

Role 구조 및 디렉터리
text
roles/
└── pxe_server/
    ├── defaults/
    │   └── main.yml          # 기본 변수 (IP 범위, OS 이미지 등)
    ├── tasks/
    │   └── main.yml          # 메인 태스크
    ├── templates/
    │   ├── dnsmasq.conf.j2   # DHCP/TFTP 설정
    │   ├── pxelinux.cfg.j2   # PXE 메뉴
    │   └── rocky8.cfg.j2     # Kickstart 템플릿
    ├── files/
    │   └── rocky-repo/       # Rocky repo 파일 (선택)
    └── handlers/
        └── main.yml          # 서비스 재시작
        
이 role을 ansible-galaxy install로 기존 role 가져온 후, templates를 당신의 환경(VMware Host-only IP 등)에 맞게 수정하세요.