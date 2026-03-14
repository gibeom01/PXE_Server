# 1. 경로 설정
$VmDir = "D:\VMware\Win2019"
$IsoPath = "D:\Windows_Server\Windows_Server_2019.iso"
$VdiskMgr = "C:\Program Files (x86)\VMware\VMware Workstation\vmware-vdiskmanager.exe"

# 2. 폴더 확인 및 생성 (이 부분이 누락되어 에러가 났었습니다)
if (-not (Test-Path $VmDir)) {
    New-Item -ItemType Directory -Force -Path $VmDir | Out-Null
    Write-Host ">> 작업 폴더를 새로 생성했습니다: $VmDir" -ForegroundColor Yellow
}

# 3. 가상 디스크 파일이 없는 경우에만 생성 (기존 파일 유지)
if (-not (Test-Path "$VmDir\disk0.vmdk")) {
    & $VdiskMgr -c -s 60GB -a lsilogic -t 0 "$VmDir\disk0.vmdk" | Out-Null
    & $VdiskMgr -c -s 60GB -a lsilogic -t 0 "$VmDir\disk1.vmdk" | Out-Null
    Write-Host ">> 가상 디스크 파일을 생성했습니다." -ForegroundColor Cyan
}

# 4. VMX 내용 (PCIe 슬롯 에러 해결 버전)
$VmxContent = @"
.encoding = "windows-1252"
config.version = "8"
virtualHW.version = "19"
guestOS = "windows2019srv-64"
memsize = "4096"
numvcpus = "2"
mks.keyboardFilter = "allow"
keyboard.vusb.enable = "TRUE"
usb.present = "TRUE"
usb.generic.allowHID = "TRUE"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
pciBridge5.present = "TRUE"
pciBridge5.virtualDev = "pcieRootPort"
pciBridge5.functions = "8"
ethernet0.present = "TRUE"
ethernet0.connectionType = "nat"
scsi0.present = "TRUE"
scsi0.virtualDev = "lsisas1068"
scsi0:0.present = "TRUE"
scsi0:0.fileName = "disk0.vmdk"
scsi0:1.present = "TRUE"
scsi0:1.fileName = "disk1.vmdk"
ide1:0.present = "TRUE"
ide1:0.fileName = "$IsoPath"
ide1:0.deviceType = "cdrom-image"
ide1:1.present = "TRUE"
ide1:1.fileName = "unattend.iso"
ide1:1.deviceType = "cdrom-image"
firmware = "bios"
"@

# 5. 설정 파일 저장
Set-Content -Path "$VmDir\Win2019.vmx" -Value $VmxContent -Encoding Ascii
Write-Host ">> [1단계 완료] 모든 설정이 정상적으로 준비되었습니다." -ForegroundColor Green
