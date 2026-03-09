# 네트워크 설정 (Host-only)
# PXE 테스트를 위해 Host-only 네트워크를 미리 VMware에서 생성하세요 (VMnet1 기본 또는 커스텀 VMnet8).

# Edit > Virtual Network Editor에서 VMnet1(Host-only) 선택, DHCP 비활성화 (PXE 서버가 담당).
#IP 범위: 192.168.56.0/24 (PXE 서버: .10, 클라이언트: .50~).

# Terraform에서는 network 리소스를 별도로 관리할 수 없으므로, VM 생성 시 network_name으로 지정합니다.

# PXE 서버 VM 생성 예제
# Rocky Linux 기반 PXE 서버 VM을 생성합니다. (미리 Rocky ISO 준비 후 guest_os_iso_path 지정).

resource "vmworkstation_vm" "pxe_server" {
  name              = "pxe-server"
  guest_os_type     = "centos-64"  # Rocky/CentOS 호환
  num_vcpus         = 4
  memory_mb         = 8192
  firmware          = "bios"  # 또는 "efi"
  
  network_adapters {
    network_type    = "host-only"
    network_name    = "VMnet1"  # Host-only 네트워크 이름
    mac_address     = "00:50:56:xx:xx:xx"  # 고정 MAC (선택)
  }
  
  disks {
    scsi {
      controller0 {
        disk {
          path       = "/path/to/pxe-server.vmdk"
          size_gb    = 60
        }
      }
    }
  }
  
  cdrom {
    iso_path = "/path/to/Rocky-8.9-x86_64-minimal.iso"
  }
  
  # 자동 부팅 및 power on
  run_state         = "running"
  expect_guest_heartbeat = true
}

# 이 VM을 생성한 후, Ansible로 PXE 서비스(DHCP/TFTP/HTTP)와 Kickstart 파일을 설치합니다