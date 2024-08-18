#!/bin/bash

apt update -yqq
apt install docker.io -yqq

systemctl enable --now docker
systemctl status docker

curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list

apt update -yqq
apt install kubeadm kubelet kubectl -yqq

apt-mark hold kubeadm kubelet kubectl
kubeadm version

swapoff -a
sed -i '/ swap / s/^\(.\*\)$/#\1/g' /etc/fstab

cat <<EOF > /etc/modules-load.d/containerd.conf
overlay
br_netfilter
EOF

modprobe overlay
modprobe br_netfilter

cat <<EOF > /etc/sysctl.d/kubernetes.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF

echo 'KUBELET_EXTRA_ARGS="--cgroup-driver=cgroupfs"' >> /etc/default/kubelet

systemctl daemon-reload && sudo systemctl restart kubelet

cat <<EOF > /etc/docker/daemon.json
{
"exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts": {
"max-size": "100m"
},

       "storage-driver": "overlay2"
       }

systemctl daemon-reload && sudo systemctl restart docker

echo 'Environment="KUBELET_EXTRA_ARGS=--fail-swap-on=false"' >> /etc/systemd/system/kubelet.service.d/10-kubeadm.conf

systemctl daemon-reload && sudo systemctl restart kubelet
kubeadm init --control-plane-endpoint=master-node --upload-certs

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml

kubectl taint nodes --all node-role.kubernetes.io/control-plane-
