#!/bin/bash
set -euo pipefail

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"
DB_NAME="${DB_NAME:-radius}"
DB_USER="${DB_USER:-radius}"
DB_PASSWORD="${DB_PASSWORD:-radiusSecret123}"

echo "=========================================="
echo "  FreeRADIUS - Iniciando"
echo "  DB: ${DB_USER}@${DB_HOST}:${DB_PORT}/${DB_NAME}"
echo "=========================================="

echo "[INFO] Aguardando MariaDB em ${DB_HOST}:${DB_PORT}..."
until nc -z -w 2 "${DB_HOST}" "${DB_PORT}"; do
  echo "[INFO] Banco ainda indisponivel... aguardando 2s"
  sleep 2
done
echo "[INFO] Banco disponivel!"

# Se foi montado um custom_clients.conf, copia para clients.conf com permissoes seguras
if [ -f "/etc/freeradius/custom_clients.conf" ]; then
  echo "[INFO] Aplicando configuracao de clientes customizada..."
  RADIUS_SHARED_SECRET="${RADIUS_SHARED_SECRET:-testing123}"
  TMP_CLIENTS="$(mktemp)"
  cp /etc/freeradius/custom_clients.conf "$TMP_CLIENTS"
  python3 - "$RADIUS_SHARED_SECRET" "$TMP_CLIENTS" <<'PY'
import re
import sys
from pathlib import Path

secret = sys.argv[1]
path = Path(sys.argv[2])
text = path.read_text(encoding='utf-8')
new_lines = []
for line in text.splitlines():
    if re.match(r'^\s*secret\s*=', line):
        new_lines.append(f'  secret    = {secret}')
    else:
        new_lines.append(line)
path.write_text('\n'.join(new_lines) + '\n', encoding='utf-8')
PY
  cp "$TMP_CLIENTS" /etc/freeradius/clients.conf
  rm -f "$TMP_CLIENTS"
  chown root:freerad /etc/freeradius/clients.conf
  chmod 640 /etc/freeradius/clients.conf
fi

SQL_CONF="/etc/freeradius/mods-available/sql"

if [ -f "$SQL_CONF" ]; then
  echo "[INFO] Configurando modulo SQL..."
  sed -i 's/dialect = "sqlite"/dialect = "mysql"/' "$SQL_CONF"
  sed -i 's/driver = "rlm_sql_null"/driver = "rlm_sql_mysql"/' "$SQL_CONF"
  sed -i "s/#\tserver = \"localhost\"/\tserver = \"${DB_HOST}\"/" "$SQL_CONF"
  sed -i "s/#\tport = 3306/\tport = ${DB_PORT}/" "$SQL_CONF"
  sed -i "s/#\tlogin = \"radius\"/\tlogin = \"${DB_USER}\"/" "$SQL_CONF"
  sed -i "s/#\tpassword = \"radpass\"/\tpassword = \"${DB_PASSWORD}\"/" "$SQL_CONF"
  sed -i "s/radius_db = \"radius\"/radius_db = \"${DB_NAME}\"/" "$SQL_CONF"
  sed -i 's/#\tread_clients = yes/\tread_clients = yes/' "$SQL_CONF"

  # Desabilita bloco tls de exemplo no mysql para conexao local sem SSL
  sed -i '/mysql {/,/warnings = auto/ { /tls {/,/}/ s/^/#/ }' "$SQL_CONF"

  ln -sf /etc/freeradius/mods-available/sql /etc/freeradius/mods-enabled/sql
  chmod 640 "$SQL_CONF"
fi

# Configuracao do modulo LDAP
LDAP_ENABLED="${LDAP_ENABLED:-true}"
LDAP_HOST="${LDAP_HOST:-openldap}"
LDAP_PORT="${LDAP_PORT:-389}"
LDAP_BASE_DN="${LDAP_BASE_DN:-dc=empresa,dc=local}"
LDAP_ADMIN_DN="${LDAP_ADMIN_DN:-cn=admin,dc=empresa,dc=local}"
LDAP_ADMIN_PASSWORD="${LDAP_ADMIN_PASSWORD:-adminSecret123}"

LDAP_CONF="/etc/freeradius/mods-available/ldap"

if [ "${LDAP_ENABLED}" = "true" ] && [ -f "$LDAP_CONF" ]; then
  echo "[INFO] Configurando modulo LDAP..."
  sed -i "s|server = 'localhost'|server = '${LDAP_HOST}'|" "$LDAP_CONF"
  sed -i "s|#\tport = 389|\tport = ${LDAP_PORT}|" "$LDAP_CONF"
  sed -i "s|#\tidentity = 'cn=admin,dc=example,dc=org'|\tidentity = '${LDAP_ADMIN_DN}'|" "$LDAP_CONF"
  sed -i "s|#\tpassword = mypass|\tpassword = '${LDAP_ADMIN_PASSWORD}'|" "$LDAP_CONF"
  sed -i "s|base_dn = 'dc=example,dc=org'|base_dn = '${LDAP_BASE_DN}'|" "$LDAP_CONF"
  # Habilita busca automatica em todas as sub-pastas e sub-arvores de projetos (scope = 'sub')
  sed -i -E "s/#[[:space:]]*scope = 'sub'/\t\tscope = 'sub'/g" "$LDAP_CONF"
  sed -i -E "s/#[[:space:]]*membership_filter = \"\(\|\(member=/\t\tmembership_filter = \"\(\|\(member=/g" "$LDAP_CONF"

  # Mantem o mapeamento NT-Password do Samba alinhado com a configuracao aplicada no ambiente em execucao
  for ldap_module in "$LDAP_CONF" "/etc/freeradius/3.0/mods-available/ldap"; do
    if [ -f "$ldap_module" ] && ! grep -q "control:NT-Password.*sambaNTPassword" "$ldap_module"; then
      sed -i "/control:Password-With-Header/ a\\
        control:NT-Password             := 'sambaNTPassword'" "$ldap_module"
    fi
    if [ -f "$ldap_module" ] && ! grep -q "reply:Tunnel-Type.*radiusTunnelType" "$ldap_module"; then
      sed -i "/control:NT-Password/ a\\
        reply:Tunnel-Type               := 'radiusTunnelType'\
        reply:Tunnel-Medium-Type        := 'radiusTunnelMediumType'\
        reply:Tunnel-Private-Group-ID   := 'radiusTunnelPrivateGroupId'\
        reply:Ubiquiti-VLAN-ID          := 'ubiquitiVlanId'" "$ldap_module"
    fi
  done

  # Link de compatibilidade para referencias /etc/freeradius/3.0
  mkdir -p /etc/freeradius
  ln -sfn /etc/freeradius /etc/freeradius/3.0

  ln -sf /etc/freeradius/mods-available/ldap /etc/freeradius/mods-enabled/ldap
  chmod 640 "$LDAP_CONF"

  # Habilita suporte a autenticacao LDAP nos sites default e inner-tunnel
  if [ -f "/etc/freeradius/sites-available/default" ]; then
    echo "[INFO] Habilitando Auth-Type LDAP no site default..."
    sed -i '/#\tif ((ok || updated) && User-Password && !control:Auth-Type)/,/#\t}/ s/^#//' /etc/freeradius/sites-available/default
    sed -i '/#\tAuth-Type LDAP {/,/#\t}/ s/^#//' /etc/freeradius/sites-available/default
  fi

  if [ -f "/etc/freeradius/sites-available/inner-tunnel" ]; then
    echo "[INFO] Habilitando Auth-Type LDAP no site inner-tunnel..."
    sed -i '/#\tif (!&control:Auth-Type && &User-Password)/,/#\t}/ s/^#//' /etc/freeradius/sites-available/inner-tunnel
    sed -i '/#\tAuth-Type LDAP {/,/#\t}/ s/^#//' /etc/freeradius/sites-available/inner-tunnel
  fi
fi

# Garante o dicionario do Vendor Ubiquiti / UBNT (41112)
if ! grep -q "VENDOR Ubiquiti 41112" /etc/freeradius/dictionary 2>/dev/null; then
  echo "[INFO] Adicionando dicionario Ubiquiti / UBNT..."
  cat << 'EOF' >> /etc/freeradius/dictionary

# Ubiquiti Networks (UBNT) Vendor Dictionary (Vendor ID: 41112)
VENDOR		Ubiquiti	41112
VENDOR		UBNT		41112

BEGIN-VENDOR	Ubiquiti
ATTRIBUTE	Ubiquiti-Data-Rate-DL		1	integer
ATTRIBUTE	Ubiquiti-Data-Rate-UL		2	integer
ATTRIBUTE	Ubiquiti-VLAN-ID		3	integer
ATTRIBUTE	Ubiquiti-Rate-Limit-Down	4	integer
ATTRIBUTE	Ubiquiti-Rate-Limit-Up		5	integer
ATTRIBUTE	Ubiquiti-Traffic-Quota-Down	6	integer
ATTRIBUTE	Ubiquiti-Traffic-Quota-Up	7	integer
ATTRIBUTE	Ubiquiti-Bandwidth-Max-Down	8	integer
ATTRIBUTE	Ubiquiti-Bandwidth-Max-Up	9	integer
ATTRIBUTE	Ubiquiti-VLAN			10	integer
ATTRIBUTE	Ubiquiti-Wifi-Device		11	string
ATTRIBUTE	Ubiquiti-OS-Version		12	string
ATTRIBUTE	Ubiquiti-Device-Model		13	string
ATTRIBUTE	Ubiquiti-Traffic-Quota		14	integer
END-VENDOR	Ubiquiti

BEGIN-VENDOR	UBNT
ATTRIBUTE	UBNT-Data-Rate-DL		1	integer
ATTRIBUTE	UBNT-Data-Rate-UL		2	integer
ATTRIBUTE	UBNT-VLAN-ID			3	integer
ATTRIBUTE	UBNT-Rate-Limit-Down		4	integer
ATTRIBUTE	UBNT-Rate-Limit-Up		5	integer
END-VENDOR	UBNT
EOF
fi

mkdir -p /var/log/freeradius
chown -R freerad:freerad /var/log/freeradius

# Ajusta permissoes do diretorio de configuracao sem falhar em mounts ro
chown -R root:freerad /etc/freeradius 2>/dev/null || true
chmod 750 /etc/freeradius 2>/dev/null || true

echo "[INFO] Validando configuracao FreeRADIUS..."
freeradius -C -l stdout

echo "[INFO] Configuracao validada com sucesso! Iniciando FreeRADIUS..."
exec "$@"
