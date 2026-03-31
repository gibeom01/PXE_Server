# 1. 테스트 환경 권장 사양 (VM 구성)
###### 최소 VM 3대 이상이 필요합니다. (마스터 노드 고가용성 학습 기준)
## VM 1, 2 (Master Nodes + HAProxy + Keepalived 겸용)
###### CPU: 2 Core / RAM: 4GB / Disk: 40GB 이상
###### 역할: K8s 마스터 노드 실행 + 로드밸런싱(HAProxy) + VIP 관리(Keepalived)
## VM 3 (Worker Node)
###### CPU: 2 Core / RAM: 4GB / Disk: 40GB 이상
###### 역할: 실제 컨테이너(Pod)가 실행되는 노드
### 네트워크 (중요): 모든 VM은 동일한 Port Group(VLAN)에 있어야 하며, 고정 IP를 할당해야 합니다.
# 2. 도구별 상세 역할 및 설정 포인트
## ① Keepalived: 가상 IP(VIP) 생성
###### 물리적(혹은 가상) 서버 2대를 하나로 묶어주는 대표 IP를 만듭니다.
### 원리: VM 1이 죽으면 VM 2가 즉시 VIP를 이어받습니다.
#### 학습 포인트: check_haproxy 스크립트를 작성하여 HAProxy 프로세스가 죽었을 때 자동으로 VIP를 넘기도록(Failover) 설정하는 법을 익힙니다.
## ② HAProxy: API 서버 부하 분산
###### K8s의 심장인 kube-apiserver는 6443 포트를 사용합니다.
### 설정: VIP의 6443 포트로 들어오는 요청을 각 마스터 노드의 실제 IP:6443으로 전달합니다.
### 학습 포인트: haproxy.cfg 파일 내에 frontend와 backend 설정을 통해 L4 로드밸런싱을 구성하는 법을 배웁니다.
## ③ Kubeadm: 클러스터 배포
###### 설정: kubeadm init 실행 시 --control-plane-endpoint "VIP:6443" 옵션을 주는 것이 핵심입니다.
###### 학습 포인트: 개별 서버가 아닌 VIP(로드밸런서)를 바라보게 클러스터를 구성하여, 마스터 한 대가 꺼져도 kubectl 명령어가 동작하는 것을 확인합니다.
# 3. 단계별 구축 로드맵 (실습 순서)
### OS 준비: 모든 VM에 Ubuntu 22.04 또는 Rocky Linux 9 설치.
### 커널 설정: Swap 비활성화, 브릿지 네트워크 설정 (sysctl 설정).
### 고가용성 구성:
###### VM 1, 2에 keepalived, haproxy 설치 및 설정.
###### VIP(예: 192.168.0.100)가 정상적으로 핑(Ping)이 가는지 확인.
### K8s 컴포넌트 설치: 모든 노드에 kubeadm, kubelet, kubectl, containerd 설치.
### 클러스터 초기화:
###### kubeadm init --control-plane-endpoint "192.168.0.100:6443" --upload-certs
### 노드 조인: 워커 노드를 클러스터에 연결.
### 네트워크(CNI) 설치: Calico 등을 설치하여 파드 간 통신 활성화.
# ⚠️ ESXi 환경 주의사항
## Promiscuous Mode (무차별 모드): Keepalived의 VIP가 제대로 작동하려면 ESXi의 가상 스위치(vSwitch) 설정에서 보안 정책(Promiscuous Mode, MAC Address Changes, Forged Transmits)을 모두 Accept로 변경해야 할 수도 있습니다. (VIP 패킷 차단 방지)
## 리소스 할당: SSD 용량은 최소 20~40GB 정도로 넉넉히 잡아주세요. (로그 및 컨테이너 이미지 저장 공간 필요)
