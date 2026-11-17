import subprocess

sql = """
ALTER USER 'radius'@'%' IDENTIFIED BY 'qHm-Eh65RX48TR_KuZJN_BFz';
ALTER USER 'root'@'%' IDENTIFIED BY 'FhXXPsyWAcrcHTqKS0t-KrVp';
ALTER USER 'root'@'localhost' IDENTIFIED BY 'FhXXPsyWAcrcHTqKS0t-KrVp';
FLUSH PRIVILEGES;
"""

cmd = ["docker", "exec", "-i", "freeradius-db", "mysql", "-uroot", "-prootSecret123"]
res = subprocess.run(cmd, input=sql, text=True, capture_output=True)
print("Return code:", res.returncode)
print("Stdout:", res.stdout)
print("Stderr:", res.stderr)

# Verify new password for radius
test_radius = subprocess.run(["docker", "exec", "-i", "freeradius-db", "mysql", "-uradius", "-pqHm-Eh65RX48TR_KuZJN_BFz", "radius", "-e", "SELECT 1 as connected;"], text=True, capture_output=True)
print("Radius test connected:", "connected" in test_radius.stdout)

# Verify new password for root
test_root = subprocess.run(["docker", "exec", "-i", "freeradius-db", "mysql", "-uroot", "-pFhXXPsyWAcrcHTqKS0t-KrVp", "-e", "SELECT 1 as connected;"], text=True, capture_output=True)
print("Root test connected:", "connected" in test_root.stdout)
