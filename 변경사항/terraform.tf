# 네트워크 대역 변경 (예: 192.168.56.0 → 10.0.0.0)

# Terraform 수정 부분 (VM 생성 단계)
# provider "vmworkstation": 변경 없음.

# vmworkstation_vm 리소스:
network_adapters {
  network_type    = "host-only"
  network_name    = "VMnet1"  # VMware GUI에서 새 Host-only 네트워크 생성 후 이름 변경
  # mac_address는 그대로
}

# VMware GUI 작업: Virtual Network Editor에서 새 VMnet(예: VMnet2) 생성 → Connect a host virtual adapter → IP 대역 10.0.0.0/24 설정 → DHCP off.

# variables.tf 추가:
variable "network_name" { default = "VMnet2" }
variable "pxe_network" { default = "10.0.0.0" }

# terraform apply 후 새 VM들이 해당 네트워크에 붙음.

---
# OS 종류 변경 시 수정 부분
# 1) Linux → Linux (Rocky 8 → CentOS 7 등)

# Terraform: 거의 변경 없음.

# guest_os_type: "centos-64" → "centos-7" (선택적, 부팅만 잘 되면 무관).
# cdrom.iso_path: CentOS 7 ISO 경로로 변경.

# 2) Linux → Windows (WDS 사용)

resource "vmworkstation_vm" "pxe_server" {
  guest_os_type     = "windows9srv-64"  # Windows Server 2019/2022
  cdrom {
    iso_path = "/path/to/Windows_Server_2022.iso"
  }
  # Windows는 설치 후 수동 WDS 설정 필요 (Ansible Windows 역할 별도)
}

# Windows → Linux 변경
# 반대로 하면 Terraform에서 guest_os_type = "centos-64", ISO 변경 → 기존 Linux PXE role 그대로 사용.

# 변경 순서 및 검증
변경 유형	                  Terraform 변경	                    Ansible 변경	                                         검증 순서
네트워크 대역	               VMnet 새로 만들기, network_name 변수	    defaults/main.yml 모든 IP, dnsmasq.conf.j2	             1. terraform apply  1. 테라폼 적용
                                                                                                                         2. ansible-playbook  2. 앤서블 플레이북
                                                                                                                         3. 클라이언트 PXE F12 → DHCP 할당 확인
Linux→Linux  리눅스→리눅스	   ISO 경로만	                          defaults 버전/URL, unarchive src/dest, Kickstart 템플릿	 1. 새 ISO 복사
                                                                                                                         2. ansible-playbook  2. 앤서블 플레이북
                                                                                                                         3. http://PXESERVER/ks/ 확인
Linux→Windows  리눅스→윈도우   guest_os_type, Windows ISO           전체 role 교체 (wds_server 역할)                            1. terraform apply (Windows 설치)
                            게스트 OS 유형, Windows ISO                                                                     1. Terraform 적용 (Windows 설치)
                                                                                                                         2. RDP로 WDS/DHCP/IIS 수동 설정
                                                                                                                         3. 클라이언트 PXE

# 변수 동기화 팁: Terraform outputs.tf에서 PXE 서버 IP/MAC 출력 → ansible-inventory --list 또는 lookup()으로 Ansible vars에 주입.