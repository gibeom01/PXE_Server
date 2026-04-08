terraform {
  required_version = ">= 1.0.0" # [cite: 1]
}

# tfvars에 정의된 서버 목록에서 '고유한 OS 타입'만 추출하여 배열로 만듭니다.
# 결과 예시: ["windows", "rocky", "ubuntu"]
locals {
  unique_os_types = toset([for k, v in var.servers : v.os_type])
}

# ---------------------------------------------------------
# 1. 커스텀 ISO 동적 생성 (OS 타입별 1회씩만 실행)
# ---------------------------------------------------------
resource "null_resource" "make_iso" {
  for_each = local.unique_os_types

  provisioner "local-exec" {
    command = <<EOT
      echo "=== [ ${each.key} ISO 자동 생성 시작 ] ==="
      mkdir -p logs
      cd scripts
      
      # OS 타입에 따라 적절한 ISO 리패키징 쉘 스크립트 호출 및 로그 저장
      if [ "${each.key}" = "windows" ]; then
        bash ./make_win_iso.sh > ../logs/make_iso_${each.key}.log 2>&1
      elif [ "${each.key}" = "rocky" ] || [ "${each.key}" = "ubuntu" ]; then
        bash ./make_linux_iso.sh ${each.key} > ../logs/make_iso_${each.key}.log 2>&1
      else
        echo "지원하지 않는 OS 타입입니다: ${each.key}"
        exit 1
      fi
    EOT
  }
}

# ---------------------------------------------------------
# 2. 하드웨어 병렬 프로비저닝 및 OS 배포 (장애 격리 적용)
# ---------------------------------------------------------
resource "null_resource" "hardware_provisioning" {
  for_each   = var.servers
  depends_on = [null_resource.make_iso] # OS 미설치 시 주석처리

  provisioner "local-exec" {
    # 특정 노드(예: idc-node-03) 실패 시 파이프라인 전체 중단 방지. -e 옵션으로 변수를 동적 주입합니다.
    on_failure = continue # 핵심: 이 노드에서 에러가 나도 다른 서버들의 프로비저닝은 멈추지 않고 계속 진행됨.

    command = <<EOT
      mkdir -p logs
      cd ansible
      
      echo "[${each.key}] 하드웨어 프로비저닝 시작..."
      
      # 1) 펌웨어 업데이트 (로그 파일 분리 저장)
      ansible-playbook update_firmware.yml \
        -e "idrac_ip=${each.value.idrac_ip} idrac_user=${var.global_idrac_user} idrac_password=${var.global_idrac_password} idrac_ver=${each.value.idrac_ver}" \
        2>&1 | tee ../logs/${each.key}_01_firmware.log
      
      # 2) 다중 RAID 동적 구성 (jsonencode를 통한 배열 주입)
      ansible-playbook configure_raid.yml \
        -e "idrac_ip=${each.value.idrac_ip} idrac_user=${var.global_idrac_user} idrac_password=${var.global_idrac_password}" \
        -e "clear_physical_disks=${var.clear_physical_disks}" \
        -e '{"raid_volumes": ${jsonencode(each.value.raid_volumes)}}' \
        2>&1 | tee ../logs/${each.key}_02_raid.logg
      
      # 3) 독립 웹서버 구동 및 OS 배포 # OS 미설치 시 3번 전부 주석처리
      cd ../ISO
      python3 -m http.server ${each.value.http_port} &
      HTTP_PID=$!
      cd ../ansible
      
      ansible-playbook deploy_os.yml \
        -e "idrac_ip=${each.value.idrac_ip} idrac_user=${var.global_idrac_user} idrac_password=${var.global_idrac_password} mac_http_ip=${var.mac_http_ip} http_port=${each.value.http_port} iso_name=${each.value.iso_name}" \
        2>&1 | tee ../logs/${each.key}_03_os_deploy.log
      
      echo "ISO 마운트 유지를 위해 60초 대기..."
      sleep 60
      kill $HTTP_PID
    EOT
  }
}
 
# ---------------------------------------------------------
# 3. 동적 인벤토리 생성 (OS 타입별 그룹화) # OS 미설치 시 3번 전부 주석처리
# ---------------------------------------------------------
resource "local_file" "ansible_inventory" {
  # inventory.ini에 각 서버별 임시 IP와 최종 할당할 목표 IP(target_os_ip)를 매핑해줍니다.
  content = templatefile("${path.module}/templates/inventory.tftpl", {
    servers = var.servers
  })
  filename = "${path.module}/ansible/inventory.ini"
}

# ---------------------------------------------------------
# 4. OS 사후 환경 설정 (노드별 개별 실행 및 핀셋 복구 지원) # OS 미설치 시 4번 전부 주석처리
# ---------------------------------------------------------
resource "null_resource" "os_post_config" {
  for_each   = var.servers
  depends_on = [null_resource.hardware_provisioning, local_file.ansible_inventory]
  
  provisioner "local-exec" {
    # Ansible이 실시간으로 폴링(Polling)하며 접속을 뚫어냅니다.
    # 사후 설정 단계에서도 실패 노드 격리
    on_failure = continue
    
    command = <<EOT
      cd ansible
      echo "[${each.key}] OS 사후 환경 설정 시작..."
      
      # OS 타입에 따라 실행할 Playbook 분기 및 해당 노드(--limit)만 타겟팅
      # 이렇게 해야 Terraform에서 `-replace='null_resource.os_post_config["idc-node-03"]'` 명령이 정확히 동작합니다.
      if [ "${each.value.os_type}" = "windows" ]; then
        ansible-playbook -i inventory.ini windows_config.yml --limit ${each.value.os_ip} \
          2>&1 | tee ../logs/${each.key}_04_os_config.log
      else
        ansible-playbook -i inventory.ini linux_config.yml --limit ${each.value.os_ip} \
          2>&1 | tee ../logs/${each.key}_04_os_config.log
      fi
    EOT
  }
}
