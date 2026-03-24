param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("CentOS", "Rocky", "Ubuntu")]
    [string]$OSName,
    [string]$BaseVmDir = "D:\VMware",
    [string]$CustomSshPort = "60022",
    [string]$IpAddress = "192.168.206.10",
    [string]$Netmask = "255.255.255.0",
    [string]$Prefix = "24",
    [string]$Gateway = "192.168.206.2",
    [string]$Dns = "8.8.8.8"
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
network --bootproto=static --ip=$IpAddress --netmask=$Netmask --gateway=$Gateway --nameserver=$Dns --device=ens160 --activate
rootpw --plaintext !Password2026
user --name=admin --password=!Password2026 --groups=wheel
auth --enableshadow --passalgo=sha512
firstboot --disable
ignoredisk --only-use=sda
autopart --type=lvm
clearpart --none --initlabel
reboot

%packages
@core
openssh-server
%end

%post --log=/root/ks-post.log

# 1. CentOS 7 저장소(Mirror)를 Vault로 자동 교체 (필수)
sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-Base.repo
sed -i 's/#baseurl=http:\/\/mirror.centos.org/baseurl=http:\/\/vault.centos.org/g' /etc/yum.repos.d/CentOS-Base.repo

# 2. 패키지 설치 및 서비스 설정
yum clean all
yum install -y sysstat chrony

systemctl enable sysstat --now
systemctl enable chronyd --now
systemctl disable firewalld --now

# 3. SELinux 비활성화
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# 4. SSH 포트 변경
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
%end
"@
    }
    
    "Rocky" {
        $FileName = "ks.cfg"
        $Content = @"
# Rocky Linux 8.10 Kickstart
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
%end

%post --log=/root/ks-post.log
export PATH=/sbin:/bin:/usr/sbin:/usr/bin

# 1. sysstat, chronyd 설치
dnf install -y sysstat chrony

# 2. 서비스 활성화 및 시작
systemctl enable sysstat --now
systemctl enable chronyd --now
systemctl disable firewalld --now

# 3. SELinux 비활성화
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
sed -i 's/^SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux

# 4. SSH 포트 변경
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
%end
"@
    }

    "Ubuntu" {
        $FileName = "user-data"
        $Content = @"
#cloud-config
autoinstall:
  version: 1
  locale: ko_KR.UTF-8
  keyboard:
    layout: kr
  ssh:
    install-server: true
    allow-pw: true
  packages:
    - openssh-server
  identity:
    hostname: ubuntu-vm
    password: "`$6`$exYm6SREtuiButp6`$6Z7.7m..82HbaMrc0.S.S1Tz.vU1v89kY8x.0L766yU6Cdfk1"
    username: admin
  network:
    network:
      version: 2
      ethernets:
        ens160:
          dhcp4: false
          addresses:
            - $IpAddress/$Prefix
          gateway4: $Gateway
          nameservers:
            addresses:
              - $Dns
  late-commands:
    - curtin in-target -- apt-get update
    - curtin in-target -- apt-get install -y sysstat chrony
    - curtin in-target -- systemctl enable sysstat
    - curtin in-target -- systemctl start sysstat
    - curtin in-target -- systemctl enable chrony
    - curtin in-target -- systemctl start chrony
    - curtin in-target -- sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
    - curtin in-target -- bash -c 'echo "admin:!Password2026" | chpasswd'
    - curtin in-target -- bash -c 'echo "root:!Password2026" | chpasswd'
    - curtin in-target -- ufw disable
"@
        $MetaContent = "instance-id: ubuntu-vm`nlocal-hostname: ubuntu-vm`n"
        [System.IO.File]::WriteAllText("$TargetDir\meta-data", $MetaContent, (New-Object System.Text.UTF8Encoding $false))
    }
}

$Content = $Content -replace "`r`n", "`n"
[System.IO.File]::WriteAllText("$TargetDir\$FileName", $Content, (New-Object System.Text.UTF8Encoding $false))
Write-Host ">> [2단계 완료] $OSName 용 응답 파일($FileName) 생성 완료." -ForegroundColor Green
