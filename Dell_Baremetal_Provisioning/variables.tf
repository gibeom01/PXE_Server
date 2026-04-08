variable "clear_physical_disks" {
  description = "모든 서버의 기존 RAID 구성을 무조건 초기화할지 여부 (true/false)"
  type        = bool
  default     = true
}

variable "clear_bios" {
  description = "모든 서버의 BIOS 설정을 공장 기본값으로 초기화할지 여부 (true/false)"
  type        = bool
  default     = true
}

variable "global_idrac_user" {
  description = "iDRAC 공통 관리자 계정"
  type        = string
}

variable "global_idrac_password" {
  description = "iDRAC 공통 관리자 패스워드"
  type        = string
  sensitive   = true # CLI 화면에 패스워드가 평문으로 노출되는 것을 방지합니다.
}

variable "mac_http_ip" {
  description = "가상 미디어 마운트를 위해 오픈할 Mac(제어 PC)의 IP"
  type        = string
}

variable "servers" {
  description     = "IDC 프로비저닝 대상 서버 목록"
  type            = map(object({
    idrac_ip      = string
    os_ip         = string        # OS 설치 완료 후 최종적으로 할당될 고정 IP
    idrac_ver     = string
    http_port     = number
    os_type       = string        # "windows", "rocky", "ubuntu" 등
    iso_name      = string        # 마운트할 커스텀 ISO 파일명
    
    # 다중 RAID 볼륨 구성을 위한 중첩 객체 리스트(List of Objects)
    raid_volumes  = list(object({
      name        = string
      type        = string        # "RAID 0", "RAID 1", "RAID 5" 등
      drives      = list(string)
    }))
  }))
}
