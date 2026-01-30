#!/bin/bash
set -euxo pipefail

echo "===== USER DATA STARTED ====="

# -----------------------------
# System update
# -----------------------------
dnf clean all
dnf update -y

# -----------------------------
# Install Docker
# -----------------------------
dnf install -y docker
systemctl enable docker
systemctl start docker

# Allow ec2-user to use docker
usermod -aG docker ec2-user

# -----------------------------
# Install kubectl (generic stable)
# -----------------------------
curl -LO https://dl.k8s.io/release/stable.txt
K8S_VERSION=$(cat stable.txt)
curl -LO https://dl.k8s.io/release/${K8S_VERSION}/bin/linux/amd64/kubectl
chmod +x kubectl
mv kubectl /usr/local/bin/

# -----------------------------
# Install Minikube
# -----------------------------
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
install minikube-linux-amd64 /usr/local/bin/minikube

# -----------------------------
# Prepare Minikube startup script
# -----------------------------
cat <<'EOF' > /home/ec2-user/start-minikube.sh
#!/bin/bash
set -eux

export HOME=/home/ec2-user
export CHANGE_MINIKUBE_NONE_USER=true

# Ensure docker group is active
newgrp docker <<EONG
minikube start \
  --driver=docker \
  --memory=2500mb \
  --cpus=2 \
  --container-runtime=containerd

kubectl config use-context minikube
kubectl get nodes
EONG
EOF

chmod +x /home/ec2-user/start-minikube.sh
chown ec2-user:ec2-user /home/ec2-user/start-minikube.sh

# -----------------------------
# Start Minikube as ec2-user
# -----------------------------
sudo -u ec2-user bash /home/ec2-user/start-minikube.sh
minikube start --driver=docker
echo "===== USER DATA COMPLETED ====="
