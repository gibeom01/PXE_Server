# VMware Workstaion pro 17 자동화 실행

## 1. Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

### 실행 규칙 변경
### 실행 정책은 신뢰하지 않는 스크립트로부터 사용자를 보호합니다. 실행 정책을 변경하면 about_Execution_Policies 도움말
### 항목(https://go.microsoft.com/fwlink/?LinkID=135170)에 설명된 보안 위험에 노출될 수 있습니다. 실행 정책을
### 변경하시겠습니까?
### [Y] 예(Y)  [A] 모두 예(A)  [N] 아니요(N)  [L] 모두 아니요(L)  [S] ### 일시 중단(S)  [?] 도움말 (기본값은 "N"): y

## 2. Set-Location D:\VMware_Workstation_Linux -> .ps1 파일 있는 곳으로 이동.

---

## Phase 1. 가상 머신 뼈대 만들기 (호스트 PC 환경)

### .\Deploy-LinuxVM_Bas.ps1 -OSName CentOS -> CentOS 구성 시
### .\Deploy-LinuxVM_Bas.ps1 -OSName Rocky -> Rocky 구성 시
### .\Deploy-LinuxVM_Bas.ps1 -OSName Ubuntu -> Ubuntu 구성 시

## Phase 2. 무인 응답 파일(XML) 생성 및 ISO 굽기 (호스트 PC 환경)

### .\Deploy-LinuxVM_2_Unattended -OSName CentOS -> CentOS 구성 시
### .\Deploy-LinuxVM_2_Unattended -OSName Rocky -> Rocky 구성 시
### .\Deploy-LinuxVM_2_Unattended -OSName Ubuntu -> Ubuntu 구성 시

### CentOS / Rocky
### 1. D:\VMware\Ubuntu\ 폴더 안에 ks.cfg 생성 확인. 
### 2. AnyBurn을 실행하여 "파일/폴더에서 이미지 파일 만들기"로 " ks.cfg" -> "unattend.iso"로 굽기.

### Ubuntu 20.04 이상 기준 
### 1. D:\VMware\Ubuntu\ 폴더 안에 user-data, meta-data 생성 확인. 
### 2. AnyBurn을 실행하여 "파일/폴더에서 이미지 파일 만들기"로 " user-data, meta-data" -> "cidata.iso"로 굽기.

## Phase 3. 설치 강제 트리거 (가상 머신 내부 환경)

### & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMware\CentOS\CentOS.vmx" -> 명령어로 CentOS VM 실행.
### & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMware\Rocky\Rocky.vmx" -> 명령어로 Rocky VM 실행.
### & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMware\Ubuntu\Ubuntu.vmx" -> 명령어로 Ubuntu VM 실행.

## Phase 4. 원격 접속(RDP) 자동 세팅 (설치 완료 후 VM 내부 환경)

### 1. VM에서 cmd 실행 -> "VM_Remote_Acrss.sh"실행. (오타 확인 후 진행.)
### 2. 가상 랜선 연결 후 사무실 pc 원격 접속.
