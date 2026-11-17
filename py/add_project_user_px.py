import subprocess

ldif = """dn: uid=user.projeto,ou=USUARIOS,ou=PX-TESTE,ou=PROJETOS,dc=empresa,dc=local
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
cn: Usuario Projeto PX
sn: PX
uid: user.projeto
uidNumber: 10050
gidNumber: 10001
homeDirectory: /home/user.projeto
userPassword: L@is@Projeto123.
mail: user.projeto@empresa.local
"""

res = subprocess.run([
    'docker', 'exec', '-i', 'openldap',
    'ldapadd', '-x', '-H', 'ldap://localhost',
    '-D', 'cn=admin,dc=empresa,dc=local', '-w', '1Uf;HS#%^;i}H=`5Cm{{ds1Gc'
], input=ldif, text=True, capture_output=True)
print("Return code:", res.returncode)
print("Stdout:", res.stdout)
print("Stderr:", res.stderr)
