param (
    [Parameter(Mandatory=$true)]
    [ValidateSet("CentOS", "Rocky", "Ubuntu")]
    [string]$OSName,
    [string]$BaseVmDir = "D:\VMware"
)

$TargetDir = "$BaseVmDir\$OSName"

switch ($OSName) {
    "CentOS" { $IsoPath = "D:\CentOS\CetnOS_7_x86_64_minimal_2009.iso"; $GuestOS = "centos7-64"; $UnattendIso = "unattend.iso" }
    "Rocky"  { $IsoPath = "D:\Rokey\Rocky_8.10_x86_64_minimal.iso"; $GuestOS = "rhel8-64"; $UnattendIso = "unattend.iso" }
    "Ubuntu" { $IsoPath = "D:\Ubuntu\ubuntu-24.04.4_live_server_amd64.iso"; $GuestOS = "ubuntu-64"; $UnattendIso = "unattend.iso" }
}

if (Test-Path $TargetDir) { Remove-Item -Path $TargetDir -Recurse -Force | Out-Null }
New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

$VdiskMgr = "C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe"
& $VdiskMgr -c -s 20GB -a lsilogic -t 0 "$TargetDir\disk0.vmdk" | Out-Null

$VmxLines = @(
    '.encoding = "windows-1252"',
    'config.version = "8"',
    'virtualHW.version = "19"',
    "guestOS = `"$GuestOS`"",
    'memsize = "2048"',
    'numvcpus = "2"',
    'ethernet0.present = "TRUE"',
    'ethernet0.connectionType = "nat"',
    'ethernet0.virtualDev = "vmxnet3"',
    'pciBridge0.present = "TRUE"',
    'pciBridge4.present = "TRUE"',
    'pciBridge4.virtualDev = "pcieRootPort"',
    'pciBridge4.functions = "8"',
    'pciBridge5.present = "TRUE"',
    'pciBridge5.virtualDev = "pcieRootPort"',
    'pciBridge5.functions = "8"',
    'scsi0.present = "TRUE"',
    'scsi0.virtualDev = "lsilogic"',
    'scsi0:0.present = "TRUE"',
    'scsi0:0.fileName = "disk0.vmdk"',
    'sata0.present = "TRUE"',
    'sata0:0.present = "TRUE"',
    "sata0:0.fileName = `"$IsoPath`"",
    'sata0:0.deviceType = "cdrom-image"',
    'sata0:1.present = "TRUE"',
    "sata0:1.fileName = `"$UnattendIso`"",
    'sata0:1.deviceType = "cdrom-image"',
    'floppy0.present = "FALSE"'
)

$FinalText = $VmxLines -join "`r`n"
[System.IO.File]::WriteAllText("$TargetDir\$OSName.vmx", $FinalText, [System.Text.Encoding]::ASCII)

Write-Host ">> [1단계 완료] $OSName VM 뼈대 생성 완료!" -ForegroundColor Green
