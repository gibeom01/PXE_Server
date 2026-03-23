# VMware Workstaion pro 17 자동화 실행

## 1. Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

### 실행 규칙 변경
### 실행 정책은 신뢰하지 않는 스크립트로부터 사용자를 보호합니다. 실행 정책을 변경하면 about_Execution_Policies 도움말
### 항목(https://go.microsoft.com/fwlink/?LinkID=135170)에 설명된 보안 위험에 노출될 수 있습니다. 실행 정책을
### 변경하시겠습니까?
### [Y] 예(Y)  [A] 모두 예(A)  [N] 아니요(N)  [L] 모두 아니요(L)  [S] ### 일시 중단(S)  [?] 도움말 (기본값은 "N"): y

## 2. Set-Location D:\VMware_Workstation_Windows -> .ps1 파일 있는 곳으로 이동.

---

## Phase 1. 가상 머신 뼈대 만들기 (호스트 PC 환경)

### .\Deploy-Win2019VM_1.ps1 -> 1번째 스크립트 실행.

## Phase 2. 무인 응답 파일(XML) 생성 및 ISO 굽기 (호스트 PC 환경)

### 1. .\Deploy-Win2019VM_2.ps1 -> 2번째 스크립트 실행. (주의: xmlns:wcm 선언부가 반드시 포함되어야 에러(Line 15)가 나지 않습니다.)
### 2. AnyBurn을 실행하여 "파일/폴더에서 이미지 파일 만들기"로 "autounattend.xml" -> "unattend.iso"로 굽기.

## Phase 3. 설치 강제 트리거 (가상 머신 내부 환경)

### 1. & "C:\Program Files (x86)\VMware\VMware Workstation\vmrun.exe" start "D:\VMware\Win2019\Win2019.vmx" 명령어로 VM 실행.

#### VM에서 Shift + F10 눌러 cmd 열고 "d:\setup.exe /unattend:e:\autounattend.xml" 명령어 입력. (다음으로 넘어가지 않으면 진행)

## Phase 4. 원격 접속(RDP) 자동 세팅 (설치 완료 후 VM 내부 환경)

### 1. VM에서 powershell 관리자 권한 실행 -> "VM_Remote_Acrss.ps1" 실행. (오타 확인 후 진행.)
### 2. 가상 랜선 연결 후 사무실 pc 원격 접속.

## Phase 5. cmd 원격 연결

###### 1. edit -> virtual network editor -> chande settings 에서 VMnet8 NAT 설정 확인.
###### 2. cmd -> ipconfig로 VMnet8 대역 확인 후 VM 알맞는 대역 지정 확인.
###### 3. cmd -> ssh -p 60070 admin@192.168.206.20 접속. (Port, addr 정확히 변경 후 접속.)
