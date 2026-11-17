import subprocess

admin_dn_pw = "1Uf;HS#%^;i}H=`5Cm{{ds1Gc"
new_config_pw = "Unx3z-#S-YDsO!dcb2ZPsj#K"
new_readonly_pw = "VZIbyg4!IZp-WH4BUAL2EgcM"

# 1. Generate SSHA hash for config
hash_cmd = ["docker", "exec", "-i", "openldap", "slappasswd", "-s", new_config_pw]
ssha_config = subprocess.run(hash_cmd, capture_output=True, text=True).stdout.strip()
print("SSHA config hash:", ssha_config)

# 2. Modify olcDatabase={0}config,cn=config
ldif = f"""dn: olcDatabase={{0}}config,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: {ssha_config}
"""
mod_cmd = [
    "docker", "exec", "-i", "openldap",
    "ldapmodify", "-x", "-H", "ldap://localhost",
    "-D", "cn=admin,cn=config", "-w", "configSecret123"
]
mod_res = subprocess.run(mod_cmd, input=ldif, capture_output=True, text=True)
print("ldapmodify config returncode:", mod_res.returncode)

# 3. Test bind cn=admin,cn=config with new config pw
test_config = subprocess.run([
    "docker", "exec", "-i", "openldap",
    "ldapsearch", "-x", "-H", "ldap://localhost",
    "-D", "cn=admin,cn=config", "-w", new_config_pw,
    "-b", "cn=config", "-s", "base", "dn"
], capture_output=True, text=True)
print("cn=config bind with new password success:", "result: 0 Success" in test_config.stdout)

# 4. Update password of cn=readonly,dc=empresa,dc=local
hash_cmd2 = ["docker", "exec", "-i", "openldap", "slappasswd", "-s", new_readonly_pw]
ssha_readonly = subprocess.run(hash_cmd2, capture_output=True, text=True).stdout.strip()

ldif_ro = f"""dn: cn=readonly,dc=empresa,dc=local
changetype: modify
replace: userPassword
userPassword: {ssha_readonly}
"""
mod_ro = subprocess.run([
    "docker", "exec", "-i", "openldap",
    "ldapmodify", "-x", "-H", "ldap://localhost",
    "-D", "cn=admin,dc=empresa,dc=local", "-w", admin_dn_pw
], input=ldif_ro, capture_output=True, text=True)
print("ldapmodify readonly returncode:", mod_ro.returncode)

# 5. Test bind cn=readonly with new password
test_ro = subprocess.run([
    "docker", "exec", "-i", "openldap",
    "ldapsearch", "-x", "-H", "ldap://localhost",
    "-D", "cn=readonly,dc=empresa,dc=local", "-w", new_readonly_pw,
    "-b", "dc=empresa,dc=local", "-s", "base", "dn"
], capture_output=True, text=True)
print("cn=readonly bind with new password success:", "result: 0 Success" in test_ro.stdout)
