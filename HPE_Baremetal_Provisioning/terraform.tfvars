global_ilo_user     = "root"
global_ilo_password = "calvin"
mac_http_ip           = "192.168.0.100"

# 대상 서버 목록 (for_each가 순회할 Map 데이터)
servers = {
  # 0번 서버 iLO 4 전용 RAID 1 구성.
  "hpe-node-gen9" = {
    ilo_ip      = "10.10.10.140"
    os_ip       = "192.168.50.10"
    ilo_ver     = "4" # Gen9 장비
    http_port   = 8000
    os_type     = "ubuntu"
    iso_name    = "Ubuntu-22.04-Auto.iso"
    
    # iLO 4 펌웨어를 2.50 이상으로 끌어올릴 파일 경로 (Mac 웹서버)
    ilo4_fw_url = "http://192.168.0.100:8000/ilo4_281.bin" 
    
    raid_volumes = [
      {
        name   = "OS_RAID1"
        type   = "RAID 1"
        drives = [1, 2]
      }
    ]
  }

  # 1번 서버: OS용 RAID 1과 Data용 RAID 5 혼합 구성
  "hpe-node-01"   = {
    ilo_ip      = "10.10.10.120"
    os_ip         = "192.168.50.10"
    ilo_ver     = "6"                          # Gen11 장비
    http_port     = 8001
    os_type       = "windows"                  # OS 타입 지정
    iso_name      = "Win2019_Auto.iso"         # 마운트할 ISO 이름
    raid_volumes  = [
      {
        name      = "OS_RAID1"
        type      = "RAID 1"
        drives    = [1, 2]                     # HPE 물리 드라이브 ID
      },
      {
        name      = "DATA_RAID5"
        type      = "RAID 5"
        drives    = [1, 2, 3]
      }
    ]
  },
  
  # 2번 서버: 전면 디스크 4개로 RAID 10 단일 구성
  "hpe-node-02"   = {
    ilo_ip      = "10.10.10.121"
    os_ip         = "192.168.50.11"
    ilo_ver     = "5"                          # Gen10 장비
    http_port     = 8002
    os_type       = "rocky"                    # Rocky Linux (CentOS 호환)
    iso_name      = "Rocky-8-Auto.iso"
    raid_volumes  = [
      {
        name      = "MAIN_RAID10"
        type      = "RAID 10"
        drives    = [1, 2, 3, 4]
      }
    ]
  }

  # ---------------------------------------------------------
  # [예시 1] 3번 서버: 캐시/임시 데이터 처리용 (RAID 0)
  # - 특징: 최소 1개 이상의 디스크 필요. 여기서는 디스크 2개를 묶어 속도를 극대화.
  # - 주의: 디스크 1개만 고장 나도 전체 데이터가 손실되므로 OS용으로는 부적합합니다.
  # ---------------------------------------------------------
  "hpe-node-03"   = {
    ilo_ip      = "10.10.10.123"
    os_ip         = "192.168.50.13"
    ilo_ver     = "6"
    http_port     = 8003
    os_type       = "ubuntu"                   # Ubuntu Server
    iso_name      = "Ubuntu-22.04-Auto.iso"
    raid_volumes  = [
      {
        name      = "CACHE_RAID0"
        type      = "RAID 0"
        drives    = [1, 2]
      }
    ]
  },

  # ---------------------------------------------------------
  # [예시 2] 4번 서버: 중요 데이터 아카이빙 및 백업용 (RAID 6)
  # - 특징: 최소 4개 이상의 디스크 필수. 디스크 6개를 묶어 구성.
  # - 장점: 디스크 2개가 동시에 고장 나도 데이터가 보존되는 극한의 안정성을 제공합니다.
  # ---------------------------------------------------------
  "hpe-node-04"   = {
    ilo_ip      = "10.10.10.124"
    os_ip         = "192.168.50.14"
    ilo_ver     = "5"
    http_port     = 8004
    os_type       = ""
    iso_name      = ""
    raid_volumes  = [
      {
        name      = "ARCHIVE_RAID6"
        type      = "RAID 6"
        drives    = [1, 2, 3, 4]
      }
    ]
  },

  # ---------------------------------------------------------
  # [예시 3] 5번 서버: OS(RAID 1) + 고속 데이터(RAID 0) + 백업(RAID 6) 혼합
  # - 실무에서 가장 많이 쓰이는 다중 볼륨 복합 구성
  # ---------------------------------------------------------
  "hpe-node-05"   = {
    ilo_ip      = "10.10.10.125"
    os_ip         = "192.168.50.15"
    ilo_ver     = "6"
    http_port     = 8005
    os_type       = ""
    iso_name      = ""
    raid_volumes  = [
      {
        name      = "OS_RAID1"
        type      = "RAID 1"
        drives    = [1, 2]
      },
      {
        name      = "DATA_RAID0"
        type      = "RAID 0"
        drives    = [1, 2]
      },
      {
        name      = "BACKUP_RAID6"
        type      = "RAID 6"
        drives    = [1, 2, 3, 4]
      }
    ]
  }
}
