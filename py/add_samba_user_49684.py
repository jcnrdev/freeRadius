import subprocess

ldif = """dn: sambaDomainName=EMPRESA,dc=empresa,dc=local
objectClass: top
objectClass: sambaDomain
sambaDomainName: EMPRESA
sambaSID: S-1-5-21-2345678901-3456789012-4567890123
sambaAlgorithmicRidBase: 1000

dn: cn=Domain Users,ou=groups,dc=empresa,dc=local
objectClass: top
objectClass: posixGroup
objectClass: sambaGroupMapping
cn: Domain Users
gidNumber: 10000
description: Grupo de Usuarios de Dominio Samba
sambaSID: S-1-5-21-2345678901-3456789012-4567890123-513
sambaGroupType: 2
displayName: Domain Users

dn: uid=49684,ou=USUARIOS,ou=PX-TESTE,ou=PROJETOS,dc=empresa,dc=local
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: sambaSAMAccount
cn: Joao Claudio Nascimento Rodrigues
sn: Nascimento Rodrigues
givenName: Joao Claudio
uid: 49684
uidNumber: 49684
gidNumber: 10000
homeDirectory: /home/49684
loginShell: /bin/bash
sambaSID: S-1-5-21-2345678901-3456789012-4567890123-10051
sambaPrimaryGroupSID: S-1-5-21-2345678901-3456789012-4567890123-513
sambaAcctFlags: [U          ]
sambaNTPassword: 58DCF602343319101C8644051633CD3F
sambaLMPassword: B13F44D54FBFD1134FA5418705880AA0
userPassword: l.151203.
mail: 49684@empresa.local
"""

res = subprocess.run([
    'docker', 'exec', '-i', 'openldap',
    'ldapadd', '-x', '-H', 'ldap://localhost',
    '-D', 'cn=admin,dc=empresa,dc=local', '-w', '1Uf;HS#%^;i}H=`5Cm{{ds1Gc'
], input=ldif, text=True, capture_output=True)
print("Return code:", res.returncode)
print("Stdout:", res.stdout)
print("Stderr:", res.stderr)
