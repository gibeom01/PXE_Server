# 1. 경로 설정
$VmDir = "D:\VMware\Win2019"

# 2. XML 내용 (wcm 네임스페이스 추가 및 완벽한 문법 적용)
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
        </component>
    </settings>
</unattend>
"@
# 원하는 UserAccounts, Password 40, 41번 줄에서 변경 가능.

# 3. UTF-8(BOM 없음)로 저장
[System.IO.File]::WriteAllText("$VmDir\autounattend.xml", $XmlContent, (New-Object System.Text.UTF8Encoding $false))
Write-Host ">> [2단계 완료] 에러가 수정된 autounattend.xml 파일이 생성되었습니다." -ForegroundColor Green
