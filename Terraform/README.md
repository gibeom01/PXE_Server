# 적용
terraform init
terraform plan
terraform apply

outputs.tf로 생성된 MAC/IP 정보를 Ansible inventory로 export하세요.
​

주의점 및 확장
Provider 한계: 네트워크 생성/파괴는 GUI에서 수동, VM power on/off 후 Ansible 연계 필수.

실제 서버 확장: Terraform outputs(MAC 목록)를 Ansible vars로 불러 DHCP/Kickstart 동적 생성.

디버깅: terraform apply 후 VM 콘솔에서 PXE 로그 확인, 방화벽/포트(67/68/69/80) 개방.
​

이 예제로 기본 테스트 환경이 완성되니, terraform apply 후 PXE 서버에 Ansible을 돌려보세요.