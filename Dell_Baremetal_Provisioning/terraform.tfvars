clear_physical_disks  = true
clear_bios           = true
global_idrac_user     = "root"
global_idrac_password = "calvin"
mac_http_ip           = "192.168.0.100"

# 대상 서버 목록 (for_each가 순회할 Map 데이터)
servers = {
  # 1번 서버: 14G(iDRAC 9) 장비, OS용 RAID 1과 Data용 RAID 5 혼합 구성
  "idc-node-01"   = {
    idrac_ip      = "10.10.10.120"
    os_ip         = "192.168.50.10"
    idrac_ver     = "9"                        # R640 장비 (14, 15, 16G)
    http_port     = 8001
    os_type       = "windows"                  # OS 타입 지정
    iso_name      = "Win2019_Auto.iso"         # 마운트할 ISO 이름
    raid_volumes  = [
      {
        name      = "OS_RAID1"
        type      = "RAID 1"
        drives    = [
          "Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      },
      {
        name      = "DATA_RAID5"
        type      = "RAID 5"
        drives    = [
          "Disk.Bay.2:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.3:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.4:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      }
    ]
  },
  
  # 2번 서버: 13G(iDRAC 8) 장비, 전면 디스크 4개로 RAID 10 단일 구성
  "idc-node-02"   = {
    idrac_ip      = "10.10.10.121"
    os_ip         = "192.168.50.11"
    idrac_ver     = "8"                        # R630 장비 (13G)
    http_port     = 8002
    os_type       = "rocky"                    # Rocky Linux (CentOS 호환)
    iso_name      = "Rocky-8-Auto.iso"
    raid_volumes  = [
      {
        name      = "MAIN_RAID10"
        type      = "RAID 10"
        drives    = [
          "Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.2:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.3:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      }
    ]
  }

  # ---------------------------------------------------------
  # [예시 1] 3번 서버: 캐시/임시 데이터 처리용 (RAID 0)
  # - 특징: 최소 1개 이상의 디스크 필요. 여기서는 디스크 2개를 묶어 속도를 극대화.
  # - 주의: 디스크 1개만 고장 나도 전체 데이터가 손실되므로 OS용으로는 부적합합니다.
  # ---------------------------------------------------------
  "idc-node-03"   = {
    idrac_ip      = "10.10.10.123"
    os_ip         = "192.168.50.13"
    idrac_ver     = "7"                        # R620 장비 (12G)
    http_port     = 8003
    os_type       = "ubuntu"                   # Ubuntu Server
    iso_name      = "Ubuntu-22.04-Auto.iso"
    raid_volumes  = [
      {
        name      = "CACHE_RAID0"
        type      = "RAID 0"
        drives    = [
          "Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      }
    ]
  },

  # ---------------------------------------------------------
  # [예시 2] 4번 서버: 중요 데이터 아카이빙 및 백업용 (RAID 6)
  # - 특징: 최소 4개 이상의 디스크 필수. 디스크 6개를 묶어 구성.
  # - 장점: 디스크 2개가 동시에 고장 나도 데이터가 보존되는 극한의 안정성을 제공합니다.
  # ---------------------------------------------------------
  "idc-node-04"   = {
    idrac_ip      = "10.10.10.124"
    os_ip         = "192.168.50.14"
    idrac_ver     = "9"
    http_port     = 8004
    os_type       = ""
    iso_name      = ""
    raid_volumes  = [
      {
        name      = "ARCHIVE_RAID6"
        type      = "RAID 6"
        drives    = [
          "Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.2:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.3:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.4:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.5:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      }
    ]
  },

  # ---------------------------------------------------------
  # [예시 3] 5번 서버: OS(RAID 1) + 고속 데이터(RAID 0) + 백업(RAID 6) 혼합
  # - 실무에서 가장 많이 쓰이는 다중 볼륨 복합 구성
  # ---------------------------------------------------------
  "idc-node-05"   = {
    idrac_ip      = "10.10.10.125"
    os_ip         = "192.168.50.15"
    idrac_ver     = "8"
    http_port     = 8005
    os_type       = ""
    iso_name      = ""
    raid_volumes  = [
      {
        name      = "OS_RAID1"
        type      = "RAID 1"
        drives    = [
          "Disk.Bay.0:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.1:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      },
      {
        name      = "DATA_RAID0"
        type      = "RAID 0"
        drives    = [
          "Disk.Bay.2:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.3:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      },
      {
        name      = "BACKUP_RAID6"
        type      = "RAID 6"
        drives    = [
          "Disk.Bay.4:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.5:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.6:Enclosure.Internal.0-1:RAID.Integrated.1-1",
          "Disk.Bay.7:Enclosure.Internal.0-1:RAID.Integrated.1-1"
        ]
      }
    ]
  }
}
