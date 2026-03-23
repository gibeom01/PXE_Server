param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("CentOS", "Rocky", "Ubuntu")]
    [string]$OSName,
    
    [string]$BaseVmDir = "D:\VMware",
    
    # --- 커스텀 설정 항목 ---
    [string]$CustomSshPort = "60022",         # 60022 포트
    [string]$IpAddress = "192.168.206.10",    # 원하는 IP 주소
    [string]$Netmask = "255.255.255.0",       # 서브넷 마스크
    [string]$Prefix = "24",                   # Ubuntu용 서브넷 프리픽스
    [string]$Gateway = "192.168.206.2",       # 게이트웨이 주소
    [string]$Dns = "8.8.8.8"                  # DNS 서버
)

$TargetDir = "$BaseVmDir\$OSName"
Write-Host ">> [$OSName] 무인 설치 응답 파일 생성 시작 (IP: $IpAddress)" -ForegroundColor Cyan

switch ($OSName) {
    "CentOS" {
        $FileName = "ks.cfg"
        $Content = @"
# CentOS 7 Kickstart
text
cdrom
lang ko_KR.UTF-8
keyboard --vckeymap=kr --xlayouts='kr'
timezone Asia/Seoul --isUtc
# DHCP 대신 정적(Static) IP 설정 적용
network --bootproto=static --ip=$IpAddress --netmask=$Netmask --gateway=$Gateway --nameserver=$Dns --device=enp0s17 --activate
rootpw --plaintext !Password2026
user --name=admin --password=!Password2026 --groups=wheel
auth --enableshadow --passalgo=sha512
firstboot --disable
ignoredisk --only-use=sda
autopart --type=lvm
clearpart --none --initlabel
reboot

%packages
@^minimal
openssh-server
sysstat
chrony
%end

%post --log=/root/ks-post.log

# 1. SELinux 비활성화
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# 2. SSH 포트 변경
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config

# 3. 방화벽(firewalld) 비활성화
systemctl disable firewalld.service

# 4. sysstat 시작 및 활성화
systemctl enable sysstat.service

# 5. chronyd 시작 및 활성화
systemctl enable chronyd.service
%end
"@
    }
    
    "Rocky" {
        $FileName = "ks.cfg"
        $Content = @"
# Rocky Linux 8 Kickstart
text
cdrom
lang en_US.UTF-8
keyboard --vckeymap=kr --xlayouts='kr'
timezone Asia/Seoul --isUtc
# DHCP 대신 정적(Static) IP 설정 적용
network --bootproto=static --ip=$IpAddress --netmask=$Netmask --gateway=$Gateway --nameserver=$Dns --device=link --activate
services --enabled="sshd"
rootpw --plaintext !Password2026
user --name=admin --password=!Password2026 --groups=wheel
firstboot --disable
ignoredisk --only-use=sda
autopart --type=lvm
clearpart --none --initlabel
reboot

%packages
@^minimal-environment
openssh-server
sysstat
chrony
%end

%post --log=/root/ks-post.log
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# 1. SELinux 비활성화
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# 2. SSH 포트 변경
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config

# 3. 방화벽(firewalld) 비활성화
systemctl disable firewalld.service

# 4. sysstat 활성화
systemctl enable sysstat.service

# 5. chronyd 활성화
systemctl enable chronyd.service
%end
"@
    }

    "Ubuntu" {
        $FileName = "user-data"
        $Content = @"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-vm
    password: "`$6`$exYm6SREtuiButp6`$6Z7.7m..82HbaMrc0.S.S1Tz.vU1v89kY8x.0L766yU6Cdfk1"
    username: admin
  locale: ko_KR.UTF-8
  keyboard:
    layout: kr
  ssh:
    install-server: true
    allow-pw: true
  network:
    network:
      version: 2
      ethernets:
        ens33:
          dhcp4: false
          addresses: ["$IpAddress/$Prefix"]
          gateway4: $Gateway
          nameservers:
            addresses: ["$Dns"]
  packages:
    - sysstat
    - chrony
  late-commands:
    # 0. admin 및 root 계정 비밀번호를 !Password2026 으로 강제 변경 (평문 적용 우회)
    - curtin in-target -- bash -c 'echo "admin:!Password2026" | chpasswd'
    - curtin in-target -- bash -c 'echo "root:!Password2026" | chpasswd'

    # 1. Ubuntu는 AppArmor를 기본으로 사용하므로 SELinux 비활성화 불필요.

    # 2. SSH 포트 변경
    - sed -i 's/#Port 22/Port $CustomSshPort/' /target/etc/ssh/sshd_config
    - sed -i 's/Port 22/Port $CustomSshPort/' /target/etc/ssh/sshd_config

    # 3. 방화벽(UFW) 비활성화
    - curtin in-target -- ufw disable

    # 4. sysstat 활성화 (Ubuntu 전용 ENABLED 옵션 켜기)
    - sed -i 's/ENABLED="false"/ENABLED="true"/' /target/etc/default/sysstat
    - curtin in-target -- systemctl enable sysstat.service
    - curtin in-target -- systemctl restart sysstat.service
    
    # 5. chrony 활성화 (Ubuntu는 데몬명이 chrony)
    - curtin in-target -- systemctl enable chrony.service
    - curtin in-target -- systemctl restart chrony.service
"@
        [System.IO.File]::WriteAllText("$TargetDir\meta-data", "", (New-Object System.Text.UTF8Encoding $false))
    }
}

# [추가됨] 윈도우용 줄바꿈(\r\n)을 리눅스용 줄바꿈(\n)으로 강제 변환
$Content = $Content -replace "`r`n", "`n"

[System.IO.File]::WriteAllText("$TargetDir\$FileName", $Content, (New-Object System.Text.UTF8Encoding $false))
Write-Host ">> [2단계 완료] $OSName 용 응답 파일($FileName) 생성 완료." -ForegroundColor Green

# ==========================================
# 2. [에러 방지] VMX 파일 랜카드 자동 패치 로직
# ==========================================
$VmxFiles = Get-ChildItem -Path $TargetDir -Filter "*.vmx"
if ($VmxFiles.Count -gt 0) {
    foreach ($VmxFile in $VmxFiles) {
        $VmxContent = Get-Content $VmxFile.FullName
        $NeedsUpdate = $false

        # e1000 이 적혀있으면 vmxnet3 으로 치환
        if ($VmxContent -match 'ethernet0.virtualDev\s*=\s*"e1000"') {
            $VmxContent = $VmxContent -replace 'ethernet0.virtualDev\s*=\s*"e1000"', 'ethernet0.virtualDev = "vmxnet3"'
            $NeedsUpdate = $true
        }
        # 아예 해당 옵션이 안 적혀있으면 맨 아래에 강제 추가
        elseif ($VmxContent -notmatch "ethernet0.virtualDev") {
            $VmxContent += 'ethernet0.virtualDev = "vmxnet3"'
            $NeedsUpdate = $true
        }

        # 파일 덮어쓰기
        if ($NeedsUpdate) {
            Set-Content -Path $VmxFile.FullName -Value $VmxContent
            Write-Host ">> [자동 패치] $($VmxFile.Name) 파일의 네트워크 어댑터를 최신 vmxnet3로 수정했습니다. (설치 에러 방지)" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host ">> [알림] $TargetDir 폴더에 .vmx 파일이 아직 없습니다. 가상 머신 생성 후 이 스크립트를 실행하면 자동 패치됩니다." -ForegroundColor Gray
}
