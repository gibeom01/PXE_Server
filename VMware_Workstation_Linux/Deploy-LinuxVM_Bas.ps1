param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("CentOS", "Rocky", "Ubuntu")]
    [string]$OSName,
    
    [string]$BaseVmDir = "D:\VMware"
)

switch ($OSName) {
    "CentOS" {
        $IsoPath = "D:\CentOS\CetnOS_7_X86_64.iso"
        $GuestOS = "centos7-64"
        $UnattendIso = "unattend.iso"
    }
    "Rocky" {
        $IsoPath = "D:\Rokey\Rokey_8.10_X86_64.iso"
        $GuestOS = "rhel8-64"
        $UnattendIso = "unattend.iso"
    }
    "Ubuntu" {
        $IsoPath = "D:\Ubuntu\ubuntu_20.04.6_amd64.iso"
        $GuestOS = "ubuntu-64"
        $UnattendIso = "cidata.iso"
    }
}

$TargetDir = "$BaseVmDir\$OSName"

if (-not (Test-Path $TargetDir)) { 
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
    Write-Host ">> 작업 폴더를 새로 생성했습니다: $TargetDir" -ForegroundColor Yellow
}

$VdiskMgr = "C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe"
if (-not (Test-Path "$TargetDir\disk0.vmdk")) {
    & $VdiskMgr -c -s 20GB -a lsilogic -t 0 "$TargetDir\disk0.vmdk" | Out-Null
}

# 요청하신 ide1:1 설정이 포함된 VMX 내용
$VmxContent = @"
.encoding = "windows-1252"
config.version = "8"
virtualHW.version = "19"
guestOS = "$GuestOS"
memsize = "2048"
numvcpus = "2"
ethernet0.present = "TRUE"
ethernet0.connectionType = "nat"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsilogic"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "disk0.vmdk"
ide1:0.present = "TRUE"
ide1:0.fileName = "$IsoPath"
ide1:0.deviceType = "cdrom-image"
ide1:1.present = "TRUE"
ide1:1.fileName = "$UnattendIso"
ide1:1.deviceType = "cdrom-image"
floppy0.present = "FALSE" 
"@

Set-Content -Path "$TargetDir\$OSName.vmx" -Value $VmxContent -Encoding Ascii
Write-Host ">> [1단계 완료] $OSName VM 구성 준비 완료 (응답파일 ISO: $UnattendIso)" -ForegroundColor Green
