#!/usr/bin/env bash
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
  echo "Execute como root: sudo ./install-linux-host.sh"
  exit 1
fi

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y ca-certificates curl gnupg lsb-release

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

CODENAME=$(. /etc/os-release && echo "$VERSION_CODENAME")
ARCH=$(dpkg --print-architecture)
cat >/etc/apt/sources.list.d/docker.list <<EOF

deb [arch=${ARCH} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu ${CODENAME} stable
EOF

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

mkdir -p /dados/ti
chown -R 1000:1000 /dados/ti

printf "\nDocker instalado e /dados/ti preparado.\n"
printf "Agora rode: newgrp docker\n"
printf "E depois: docker pull dperson/samba:latest\n"
printf "Finalmente: docker run -d --name samba -p 445:445 -v /dados:/dados dperson/samba:latest -u '49684;Senha@123' -s 'TI;/dados/ti;yes;no;no;user'\n"
