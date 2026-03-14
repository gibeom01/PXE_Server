# !!!!!!!!!!!!!!!!! 무조건 VM안에서 실행 !!!!!!!!!!!!!!!!!

# 1. 변경할 포트 번호를 여기에 입력하세요 (기본 3389 대신 쓸 포트)
$CustomPort = 1111

Write-Host ">> 원격 데스크톱(RDP) 설정을 시작합니다..." -ForegroundColor Cyan

# 2. 레지스트리 변경 (Wds\Tds\tcp 및 WinStations\RDP-Tcp 포트 변경)
$RegPath1 = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\Wds\rdpwd\Tds\tcp"
$RegPath2 = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
Set-ItemProperty -Path $RegPath1 -Name "PortNumber" -Value $CustomPort
Set-ItemProperty -Path $RegPath2 -Name "PortNumber" -Value $CustomPort

# 3. 방화벽 인바운드 규칙 생성 (원격연결_Port)
$RuleName = "remote_access_$CustomPort"
New-NetFirewallRule -DisplayName $RuleName -Direction Inbound -LocalPort $CustomPort -Protocol TCP -Action Allow | Out-Null

# Write-Host ">> 방화벽 규칙 [$RuleName] 이 생성되었습니다." -ForegroundColor Green

# 4. 시스템 원격 접속 허용 (sysdm.cpl 체크박스 켜기)
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop" | Out-Null

# 5. 변경된 포트 적용을 위해 원격 데스크톱 서비스 재시작
Restart-Service -Name "TermService" -Force

# Write-Host ">> 설정이 완료되었습니다! 이제 $CustomPort 포트로 원격 접속이 가능합니다." -ForegroundColor Green

# !!!!!!!!!!!!!!!!! 무조건 VM안에서 실행 !!!!!!!!!!!!!!!!!