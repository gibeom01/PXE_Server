terraform {
  required_version = ">= 1.0.0"
}

# ---------------------------------------------------------
# 1단계: Windows 무인 설치용 커스텀 ISO 생성 (xorriso)
# ---------------------------------------------------------
resource "null_resource" "make_iso" {
  provisioner "local-exec" {
    # 기존에 작성한 쉘 스크립트 실행
    command = "bash ./make_iso.sh"
  }
}

# ---------------------------------------------------------
# 2단계: 14G, 15G, 16G iDRAC9 펌웨어 업데이트
# ---------------------------------------------------------
resource "null_resource" "update_firmware" {
  depends_on = [null_resource.make_iso]
  
  provisioner "local-exec" {
    command = "ansible-playbook update_firmware.yml"
  }
}

# ---------------------------------------------------------
# 3단계: 14G, 15G, 16G R640 물리 디스크 RAID 1 구성
# ---------------------------------------------------------
resource "null_resource" "configure_raid" {
  depends_on = [null_resource.update_firmware]
  
  provisioner "local-exec" {
    command = "ansible-playbook configure_raid.yml"
  }
}

# ---------------------------------------------------------
# 4단계: 가상 미디어 마운트 및 OS 무인 설치 부팅
# ---------------------------------------------------------
resource "null_resource" "deploy_os" {
  depends_on = [null_resource.configure_raid]
  
  provisioner "local-exec" {
    # Mac 내장 파이썬으로 임시 웹서버를 백그라운드(&)로 실행하고 PID를 기억
    # Ansible 실행 후 60초 대기(iDRAC이 ISO를 읽어갈 시간)한 뒤 웹서버 강제 종료
    command = <<EOT
      cd ISO
      python3 -m http.server 8000 &
      HTTP_PID=$!
      cd ..
      ansible-playbook deploy_os.yml
      echo "iDRAC ISO 마운트 유지를 위해 60초 대기 중..."
      sleep 60
      kill $HTTP_PID
    EOT
  }
}

# ---------------------------------------------------------
# 5단계: Windows OS 사후 설정 (네트워크, 방화벽, 포트)
# ---------------------------------------------------------
resource "null_resource" "windows_config" {
  depends_on = [null_resource.deploy_os]
  
  provisioner "local-exec" {
    # 기존의 sleep 1500 (25분 대기)을 과감히 삭제합니다.
    # Ansible이 실시간으로 폴링(Polling)하며 접속을 뚫어냅니다.
    command = <<EOT
      echo "🚀 OS 배포가 시작되었습니다. Ansible이 서버의 접속 응답을 실시간으로 대기합니다..."
      ansible-playbook -i inventory.ini windows_config.yml
    EOT
  }
}
