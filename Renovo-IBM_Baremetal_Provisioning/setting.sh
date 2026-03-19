#!/bin/bash
ansible-galaxy collection install community.general
pip3 install requests "pywinrm>=0.3.0"

# IBM M4 (IMM2) 전원 및 부팅 제어를 위한 IPMI 도구 설치
brew install ipmitool
