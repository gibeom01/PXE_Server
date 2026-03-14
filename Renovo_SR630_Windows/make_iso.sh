#!/bin/bash
BASE_DIR="$HOME/Desktop/Lenovo_SR630_Windows/ISO"
ORIGINAL_ISO="$BASE_DIR/Windows_Server_2019.iso"
CUSTOM_ISO="$BASE_DIR/Windows_Server_2019_Auto.iso"
XML_FILE="$BASE_DIR/autounattend.xml"
WORK_DIR="$HOME/iso_build/win_custom_lenovo"

echo "1. autounattend.xml 파일을 생성합니다..."
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

echo "2. 작업 공간 초기화 및 ISO 마운트 복사..."
mkdir -p "$WORK_DIR"
rm -rf "$WORK_DIR"/*
hdiutil attach "$ORIGINAL_ISO" -mountpoint /Volumes/Win2019 -noverify -nobrowse
cp -R /Volumes/Win2019/* "$WORK_DIR/"
hdiutil detach /Volumes/Win2019

echo "3. autounattend.xml 삽입 및 커스텀 ISO 생성..."
cp "$XML_FILE" "$WORK_DIR/autounattend.xml"
xorriso -as mkisofs -iso-level 4 -J -l -D -N -joliet-long -V "WIN2019_AUTO" -b boot/etfsboot.com -no-emul-boot -boot-load-size 8 -boot-info-table -eltorito-alt-boot -e efi/microsoft/boot/efisys.bin -no-emul-boot -udf -o "$CUSTOM_ISO" "$WORK_DIR"
