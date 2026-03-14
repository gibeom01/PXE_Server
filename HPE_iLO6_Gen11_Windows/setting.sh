#!/bin/bash
# HPE iLO Redfish 통신을 위한 Ansible Collection 설치
ansible-galaxy collection install community.general

# Redfish API 호출에 필요한 Python 라이브러리 설치
pip3 install requests
