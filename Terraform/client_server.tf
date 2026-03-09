# 빈 VM으로 PXE 부팅을 테스트합니다. 여러 대 생성해 HPE/Dell/Lenovo 시뮬레이션.

resource "vmworkstation_vm" "pxe_client_hpe" {
  name              = "test-client-hpe"
  guest_os_type     = "other-64"  # 빈 VM
  num_vcpus         = 2
  memory_mb         = 4096
  firmware          = "bios"  # PXE 부팅 시 F12 누를 수 있도록
  
  network_adapters {
    network_type    = "host-only"
    network_name    = "VMnet1"
    mac_address     = "00:0C:29:xx:xx:xx"  # DHCP에 등록될 MAC
  }
  
  disks {
    scsi {
      controller0 {
        disk {
          size_gb    = 40
        }
      }
    }
  }
  
  # 첫 부팅 시 Network Boot 우선 (VMware GUI에서 BIOS 설정 필요)
  run_state         = "running"
  extra_config      = {
    "bios.bootOrder" = "net,cdrom,floppy,hd"
  }
}

# Dell/Lenovo용 추가 클라이언트 (for_each로 확장)
resource "vmworkstation_vm" "pxe_clients" {
  for_each          = toset(["dell", "lenovo"])
  
  name              = "test-client-${each.key}"
  # ... 위와 동일 설정 (MAC만 다르게)
}

# 생성 후 클라이언트 VM을 재부팅하면 F12로 PXE 부팅 → PXE 서버에서 Rocky 설치가 시작됩니다