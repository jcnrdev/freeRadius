import subprocess

pw1 = "1Uf;HS#%^;i}H=`5Cm{{ds1Gc"
pw2 = "'1Uf;HS#%^;i}H=`5Cm{{ds1Gc'"

for pw, label in [(pw1, "raw"), (pw2, "with_quotes")]:
    res = subprocess.run([
        'docker', 'exec', 'openldap', 'ldapsearch', '-x', '-H', 'ldap://localhost',
        '-D', 'cn=admin,dc=empresa,dc=local', '-w', pw,
        '-b', 'dc=empresa,dc=local', '-s', 'base', 'dn'
    ], capture_output=True, text=True)
    print(label, "returncode:", res.returncode, "success:", "result: 0 Success" in res.stdout)
