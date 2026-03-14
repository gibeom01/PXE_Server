#!/bin/bash

# 1. 경로 변수 설정
BASE_DIR="$HOME/Desktop/Dell(14G,15G,16G)_iDRAC9_R640_Windows/ISO"
ORIGINAL_ISO="$BASE_DIR/Windows_Server_2019.iso"
CUSTOM_ISO="$BASE_DIR/Windows_Server_2019_Auto.iso"
XML_FILE="$BASE_DIR/autounattend.xml"
WORK_DIR="$HOME/iso_build/win_custom"

echo "1. autounattend.xml 파일을 생성합니다..."

# 2. 파티션 및 무인 설치 설정이 담긴 XML 파일 자동 생성
cat << 'EOF' > "$XML_FILE"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <CreatePartition wcm:action="add"><Order>1</Order><Type>EFI</Type><Size>500</Size></CreatePartition>
                        <CreatePartition wcm:action="add"><Order>2</Order><Type>MSR</Type><Size>128</Size></CreatePartition>
                        <CreatePartition wcm:action="add"><Order>3</Order><Type>Primary</Type><Size>307200</Size></CreatePartition>
                        <CreatePartition wcm:action="add"><Order>4</Order><Type>Primary</Type><Size>307200</Size></CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add"><Order>1</Order><PartitionID>1</PartitionID><Format>FAT32</Format></ModifyPartition>
                        <ModifyPartition wcm:action="add"><Order>2</Order><PartitionID>2</PartitionID></ModifyPartition>
                        <ModifyPartition wcm:action="add"><Order>3</Order><PartitionID>3</PartitionID><Format>NTFS</Format><Letter>C</Letter></ModifyPartition>
                        <ModifyPartition wcm:action="add"><Order>4</Order><PartitionID>4</PartitionID><Format>NTFS</Format><Letter>D</Letter></ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo><DiskID>0</DiskID><PartitionID>3</PartitionID></InstallTo>
                </OSImage>
            </ImageInstall>
            <UserData>
                <AcceptEula>true</AcceptEula>
            </UserData>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            <UserAccounts>
                <AdministratorPassword>
                    <Value>WinP@ss123!</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
            </UserAccounts>
            <AutoLogon>
                <Password><Value>WinP@ss123!</Value><PlainText>true</PlainText></Password>
                <Enabled>true</Enabled>
                <LogonCount>1</LogonCount>
                <Username>Administrator</Username>
            </AutoLogon>
            <FirstLogonCommands>
                <SynchronousCommand wcm:action="add">
                    <Order>1</Order>
                    <CommandLine>powershell -Command "Enable-PSRemoting -SkipNetworkProfileCheck -Force"</CommandLine>
                </SynchronousCommand>
            </FirstLogonCommands>
        </component>
    </settings>
</unattend>
EOF

echo "2. 작업용 디렉토리를 초기화합니다..."
mkdir -p "$WORK_DIR"
rm -rf "$WORK_DIR"/*

echo "3. 원본 ISO를 마운트하고 데이터를 복사합니다 (시간이 조금 걸립니다)..."
hdiutil attach "$ORIGINAL_ISO" -mountpoint /Volumes/Win2019 -noverify -nobrowse
cp -R /Volumes/Win2019/* "$WORK_DIR/"
hdiutil detach /Volumes/Win2019

echo "4. 생성된 autounattend.xml을 설치 파일 루트 경로에 삽입합니다..."
cp "$XML_FILE" "$WORK_DIR/autounattend.xml"

echo "5. 커스텀 ISO 파일(Windows_Server_2019_Auto.iso)을 생성합니다..."
xorriso -as mkisofs \
  -iso-level 4 -J -l -D -N -joliet-long \
  -V "WIN2019_AUTO" \
  -b boot/etfsboot.com -no-emul-boot -boot-load-size 8 -boot-info-table \
  -eltorito-alt-boot \
  -e efi/microsoft/boot/efisys.bin -no-emul-boot \
  -udf \
  -o "$CUSTOM_ISO" \
  "$WORK_DIR"

echo "🎉 작업 완료! $CUSTOM_ISO 파일이 성공적으로 만들어졌습니다."
