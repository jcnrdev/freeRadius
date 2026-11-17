import subprocess

res = subprocess.run([
    'docker', 'exec', '-i', 'openldap',
    'ldapsearch', '-x', '-H', 'ldap://localhost',
    '-D', 'cn=admin,dc=empresa,dc=local', '-w', '1Uf;HS#%^;i}H=`5Cm{{ds1Gc',
    '-b', 'ou=projetos,dc=empresa,dc=local', 'dn'
], capture_output=True, text=True)
print("Stdout:\n", res.stdout)
print("Stderr:\n", res.stderr)
