#!/bin/bash
set -euxo pipefail

# -----------------------------
# Basic system update
# -----------------------------
dnf update -y

# -----------------------------
# Install Docker
# -----------------------------
dnf install -y docker
systemctl enable docker
systemctl start docker

# -----------------------------
# Remove Docker memory limits (IMPORTANT for Minikube)
# -----------------------------
mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF >/etc/systemd/system/docker.service.d/override.conf
[Service]
MemoryMax=infinity
MemoryHigh=infinity
EOF

systemctl daemon-reexec
systemctl daemon-reload
systemctl restart docker

# -----------------------------
# Allow ec2-user to use Docker
# -----------------------------
usermod -aG docker ec2-user

# -----------------------------
# Install kubectl (latest stable)
# -----------------------------
K8S_VERSION=$(curl -Ls https://dl.k8s.io/release/stable.txt)
curl -LO "https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl"
install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm -f kubectl

# -----------------------------
# Install Minikube
# -----------------------------
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube
rm -f minikube-linux-amd64

# -----------------------------
# Ensure correct permissions
# -----------------------------
chown -R ec2-user:ec2-user /home/ec2-user

# -----------------------------
# Helpful message in MOTD
# -----------------------------
cat <<'EOF' >/etc/motd

✅ Minikube prerequisites installed!

Next steps (as ec2-user):
--------------------------------
newgrp docker
minikube start --driver=docker --memory=2560 --cpus=2

--------------------------------
EOF
