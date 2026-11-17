import subprocess

new_pass = "1Uf;HS#%^;i}H=`5Cm{{ds1Gc"

# 1. Generate SSHA hash using slappasswd
hash_cmd = ["docker", "exec", "-i", "openldap", "slappasswd", "-s", new_pass]
hash_res = subprocess.run(hash_cmd, capture_output=True, text=True)
ssha_hash = hash_res.stdout.strip()
print("Generated SSHA hash:", ssha_hash)

# 2. Modify olcRootPW in olcDatabase={1}mdb,cn=config
ldif = f"""dn: olcDatabase={{1}}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {ssha_hash}
"""

mod_cmd = [
    "docker", "exec", "-i", "openldap",
    "ldapmodify", "-x", "-H", "ldap://localhost",
    "-D", "cn=admin,cn=config", "-w", "configSecret123"
]
mod_res = subprocess.run(mod_cmd, input=ldif, capture_output=True, text=True)
print("ldapmodify returncode:", mod_res.returncode)
print("ldapmodify stdout:", mod_res.stdout)
print("ldapmodify stderr:", mod_res.stderr)

# 3. Test bind with the new password
test_cmd = [
    "docker", "exec", "-i", "openldap",
    "ldapsearch", "-x", "-H", "ldap://localhost",
    "-D", "cn=admin,dc=empresa,dc=local", "-w", new_pass,
    "-b", "dc=empresa,dc=local", "-s", "base", "dn"
]
test_res = subprocess.run(test_cmd, capture_output=True, text=True)
print("Test bind returncode:", test_res.returncode)
if test_res.returncode == 0 and "result: 0 Success" in test_res.stdout:
    print("SUCCESS: cn=admin,dc=empresa,dc=local successfully authenticated with the new password!")
else:
    print("FAILED bind:", test_res.stderr, test_res.stdout)
