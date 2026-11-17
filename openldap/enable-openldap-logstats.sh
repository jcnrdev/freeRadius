#!/usr/bin/env bash
set -euo pipefail

docker exec openldap bash -lc '
cat >/tmp/olc-loglevel.ldif <<"LDIF"
dn: cn=config
changetype: modify
replace: olcLogLevel
olcLogLevel: stats
LDIF
ldapmodify -Y EXTERNAL -H ldapi:/// -f /tmp/olc-loglevel.ldif
'

echo "OpenLDAP loglevel set to stats."
