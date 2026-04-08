#!/bin/bash

# 1. 경로 변수 설정 (Terraform 프로젝트 내부 상대 경로 사용)
BASE_DIR="./ISO"
ORIGINAL_ISO="$BASE_DIR/Windows_Server_2019.iso"
CUSTOM_ISO="$BASE_DIR/Windows_Server_2019_Auto.iso"
XML_FILE="$BASE_DIR/autounattend.xml"
WORK_DIR="/tmp/win_custom_build" # Mac에서 권한 충돌이 적은 tmp 디렉토리 활용

echo "1. autounattend.xml 파일을 생성합니다..."

# (XML 생성 로직은 기존과 100% 동일하므로 생략 없이 그대로 유지하시면 됩니다)
cat << 'EOF' > "$XML_FILE"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    
    <settings pass="windowsPE">
        <component name="Microsoft-Windows-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS">
            
            <UserData>
                <AcceptEula>true</AcceptEula>
            </UserData>

            <DiskConfiguration>
                <Disk wcm:action="add">
                    <DiskID>0</DiskID>
                    <WillWipeDisk>true</WillWipeDisk>
                    <CreatePartitions>
                        <CreatePartition wcm:action="add">
                            <Order>1</Order>
                            <Type>Primary</Type>
                            <Extend>true</Extend>
                        </CreatePartition>
                    </CreatePartitions>
                    <ModifyPartitions>
                        <ModifyPartition wcm:action="add">
                            <Order>1</Order>
                            <PartitionID>1</PartitionID>
                            <Format>NTFS</Format>
                            <Letter>C</Letter>
                        </ModifyPartition>
                    </ModifyPartitions>
                </Disk>
            </DiskConfiguration>
            <ImageInstall>
                <OSImage>
                    <InstallTo>
                        <DiskID>0</DiskID>
                        <PartitionID>1</PartitionID>
                    </InstallTo>
                </OSImage>
            </ImageInstall>
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

echo "3. 원본 ISO를 마운트하고 데이터를 복사합니다..."
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

echo "작업 완료! 커스텀 ISO 파일이 성공적으로 만들어졌습니다."
