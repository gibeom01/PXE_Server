param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("CentOS", "Rocky", "Ubuntu")]
    [string]$OSName,
    
    [string]$BaseVmDir = "D:\VMware",
    
    # --- 커스텀 설정 항목 ---
    [string]$CustomSshPort = "60022",
    [string]$IpAddress = "192.168.1.100",  # 원하는 IP 주소
    [string]$Netmask = "255.255.255.0",    # 서브넷 마스크
    [string]$Prefix = "24",                # Ubuntu용 서브넷 프리픽스
    [string]$Gateway = "192.168.1.1",      # 게이트웨이 주소
    [string]$Dns = "8.8.8.8"               # DNS 서버
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
network --bootproto=static --ip=$IpAddress --netmask=$Netmask --gateway=$Gateway --nameserver=$Dns --device=eth0 --activate
rootpw --plaintext Password123!
user --name=admin --password=Password123! --groups=wheel
auth --enableshadow --passalgo=sha512
firstboot --disable
ignoredisk --only-use=sda
autopart --type=lvm
clearpart --none --initlabel
reboot

%packages
@^minimal
openssh-server
firewalld
policycoreutils-python
%end

%post --log=/root/ks-post.log
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
firewall-offline-cmd --add-port=$CustomSshPort/tcp
semanage port -a -t ssh_port_t -p tcp $CustomSshPort || true
%end
"@
    }
    
    "Rocky" {
        $FileName = "ks.cfg"
        $Content = @"
# Rocky Linux 8 Kickstart
text
cdrom
lang ko_KR.UTF-8
keyboard --vckeymap=kr --xlayouts='kr'
timezone Asia/Seoul --isUtc
# DHCP 대신 정적(Static) IP 설정 적용
network --bootproto=static --ip=$IpAddress --netmask=$Netmask --gateway=$Gateway --nameserver=$Dns --device=link --activate
rootpw --plaintext Password123!
user --name=admin --password=Password123! --groups=wheel
firstboot --disable
ignoredisk --only-use=sda
autopart --type=lvm
clearpart --none --initlabel
reboot

%packages
@^minimal-environment
openssh-server
firewalld
policycoreutils-python-utils
%end

%post --log=/root/ks-post.log
sed -i 's/#Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
sed -i 's/Port 22/Port $CustomSshPort/' /etc/ssh/sshd_config
firewall-offline-cmd --add-port=$CustomSshPort/tcp
semanage port -a -t ssh_port_t -p tcp $CustomSshPort || true
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
  late-commands:
    - sed -i 's/#Port 22/Port $CustomSshPort/' /target/etc/ssh/sshd_config
    - sed -i 's/Port 22/Port $CustomSshPort/' /target/etc/ssh/sshd_config
    - curtin in-target -- ufw allow $CustomSshPort/tcp
    - curtin in-target -- ufw enable
"@
        [System.IO.File]::WriteAllText("$TargetDir\meta-data", "", (New-Object System.Text.UTF8Encoding $false))
    }
}

[System.IO.File]::WriteAllText("$TargetDir\$FileName", $Content, (New-Object System.Text.UTF8Encoding $false))
Write-Host ">> [2단계 완료] $OSName 용 응답 파일($FileName) 생성 완료." -ForegroundColor Green
