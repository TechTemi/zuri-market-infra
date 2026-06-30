#!/bin/bash
set -euxo pipefail

exec > >(tee /var/log/zuri-k3s-bootstrap.log | logger -t user-data -s 2>/dev/console) 2>&1

HOSTNAME_VALUE=$(hostname)
if ! grep -q "$HOSTNAME_VALUE" /etc/hosts; then
  echo "127.0.1.1 $HOSTNAME_VALUE" >> /etc/hosts
fi

apt-get update -y
apt-get install -y curl ca-certificates jq unzip

PUBLIC_IP="${public_ip}"

mkdir -p /etc/rancher/k3s

cat > /etc/rancher/k3s/config.yaml <<EOF
tls-san:
  - "$PUBLIC_IP"
write-kubeconfig-mode: "0644"
disable:
  - traefik
EOF

curl -sfL https://get.k3s.io | sh -

systemctl enable k3s
systemctl restart k3s

mkdir -p /home/ubuntu/.kube
cp /etc/rancher/k3s/k3s.yaml /home/ubuntu/.kube/config
chown -R ubuntu:ubuntu /home/ubuntu/.kube
chmod 600 /home/ubuntu/.kube/config

cat > /home/ubuntu/README-k3s.txt <<EOF
Zuri Market k3s node is ready.

Useful commands:
  kubectl get nodes
  kubectl get pods -A
  kubectl get all -n zuri-market

Kubeconfig:
  /etc/rancher/k3s/k3s.yaml
  /home/ubuntu/.kube/config

Bootstrap log:
  /var/log/zuri-k3s-bootstrap.log
EOF

chown ubuntu:ubuntu /home/ubuntu/README-k3s.txt

for i in $(seq 1 30); do
  if kubectl get nodes; then
    break
  fi
  sleep 10
done

kubectl get nodes
