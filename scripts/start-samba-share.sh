#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

docker compose up -d samba

echo "---"
echo "Container Samba iniciado."
echo "Teste no cliente Windows: \\IP_DA_VM\TI"
echo "Se for local na VM, use: \\127.0.0.1\TI"
echo "---"
docker compose ps samba
