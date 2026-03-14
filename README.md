주로 사용하는 서버

DELL R620, R630, R640

RENOVO SR630

HPE Gen9, Gen10, Gen11

IBM System x3550 M4
- 구형 IBM 장비는 IMM2 (Integrated Management Module II) 칩셋 사용.
- Mac에서 IBM IMM2와 통신하려면 ipmitool이 추가로 필요.
- brew install ipmitool
- ansible-galaxy collection install community.general
- 파일은 deploy_os.yml, windows_config.yml만 가능함.

---

1. terraform.tfvars, for_each 파일 작성.
2. 서버별 코드 통일. (Dell, HPE, Renove/IBM)
3. 분리한 서버별에서 OS별로 분리. (Linux, Windows)
4. 
