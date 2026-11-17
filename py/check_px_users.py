import subprocess

res = subprocess.run([
    'docker', 'exec', '-i', 'openldap',
    'ldapsearch', '-x', '-H', 'ldap://localhost',
    '-D', 'cn=admin,dc=empresa,dc=local', '-w', '1Uf;HS#%^;i}H=`5Cm{{ds1Gc',
    '-b', 'ou=USUARIOS,ou=PX-TESTE,ou=PROJETOS,dc=empresa,dc=local', '(objectclass=*)'
], capture_output=True, text=True)
print("Stdout:\n", res.stdout)
