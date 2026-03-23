# 1. 경로 및 네트워크 고정 IP 설정
$VmDir = "D:\VMware\Win2019"

# --- 커스텀 네트워크 설정 항목 ---
$IpAddress = "192.168.206.20"   # 원하는 고정 IP
$PrefixLength = "24"            # 서브넷 마스크 (24 = 255.255.255.0)
$Gateway = "192.168.206.2"      # VMware VMnet8 NAT 게이트웨이 기본값
$Dns = "8.8.8.8"                # DNS 서버

Write-Host ">> Windows Server 2019 무인 응답 파일 생성 시작 (IP: $IpAddress)" -ForegroundColor Cyan

# 2. XML 내용 (wcm 네임스페이스 및 FirstLogonCommands 네트워크 설정 추가)
$XmlContent = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-International-Core-WinPE" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <SetupUILanguage><UILanguage>en-US</UILanguage></SetupUILanguage>
            <InputLocale>0412:00000412</InputLocale>
            <SystemLocale>ko-KR</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>ko-KR</UserLocale>
        </component>
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID><WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <CreatePartition wcm:action="add"><Order>1</Order><Type>Primary</Type><Size>40000</Size></CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add"><Order>1</Order><PartitionID>1</PartitionID><Label>OS</Label><Letter>C</Letter><Format>NTFS</Format></ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo><DiskID>0</DiskID><PartitionID>1</PartitionID></InstallTo>
                    <InstallFrom><MetaData wcm:action="add"><Key>/IMAGE/INDEX</Key><Value>2</Value></MetaData></InstallFrom>
                </OSImage>
            </ImageInstall>
            <UserData><AcceptEula>true</AcceptEula></UserData>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <OOBE><HideEULAPage>true</HideEULAPage><ProtectYourPC>3</ProtectYourPC></OOBE>
            <UserAccounts><AdministratorPassword><Value>Password123!</Value><PlainText>true</PlainText></AdministratorPassword></UserAccounts>
            <AutoLogon><Password><Value>Password123!</Value><PlainText>true</PlainText></Password><Enabled>true</Enabled><LogonCount>1</LogonCount><Username>Administrator</Username></AutoLogon>
            
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <CommandLine>powershell -WindowStyle Hidden -Command "Get-NetAdapter | New-NetIPAddress -IPAddress $IpAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -Force"</CommandLine>
                    <Description>Set Static IP</Description>
                </SynchronousCommand>
                <SynchronousCommand wcm:action="add">
                    <Order>2</Order>
                    <CommandLine>powershell -WindowStyle Hidden -Command "Get-NetAdapter | Set-DnsClientServerAddress -ServerAddresses $Dns"</CommandLine>
                    <Description>Set DNS Server</Description>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
"@

# 3. UTF-8(BOM 없음)로 저장
[System.IO.File]::WriteAllText("$VmDir\autounattend.xml", $XmlContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host ">> [2단계 완료] 네트워크 설정이 포함된 autounattend.xml 파일이 생성되었습니다." -ForegroundColor Green
