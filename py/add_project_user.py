import subprocess

ldif = """dn: ou=projetos,dc=empresa,dc=local
objectClass: top
objectClass: organizationalUnit
ou: projetos

dn: ou=projeto-alpha,ou=projetos,dc=empresa,dc=local
objectClass: top
objectClass: organizationalUnit
ou: projeto-alpha

dn: uid=user.projeto,ou=projeto-alpha,ou=projetos,dc=empresa,dc=local
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
objectClass: posixAccount
cn: Usuario Projeto Alpha
sn: Alpha
uid: user.projeto
uidNumber: 10050
gidNumber: 10001
homeDirectory: /home/user.projeto
userPassword: ProjetoSenha@2026
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
