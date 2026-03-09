# 먼저 Terraform provider를 초기화하고 인증을 설정합니다.

terraform {
  required_providers {
    vmworkstation = {
      source  = "elsudano/vmworkstation"
      version = "~> 1.0"  # 최신 버전 확인 필요
    }
  }
}

provider "vmworkstation" {
  user     = var.vmws_user     # VMware Workstation 사용자명
  password = var.vmws_password # 비밀번호 (또는 API 토큰)
  url      = "http://127.0.0.1:8697"  # 기본 VMware API URL
  https    = false
  debug    = true
}

# provider는 VMware Workstation Pro의 REST API를 통해 VM 생성/관리 기능을 제공합니다.
