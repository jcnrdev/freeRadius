import subprocess

script = """<?php
require '/var/www/phpldapadmin/lib/createlm.php';
$h = new smbHash;
echo "LM_l: " . $h->lmhash('l.151203.') . "\n";
echo "NT_l: " . $h->nthash('l.151203.') . "\n";
echo "LM_L: " . $h->lmhash('L@is@151203.') . "\n";
echo "NT_L: " . $h->nthash('L@is@151203.') . "\n";
"""

res = subprocess.run(["docker", "exec", "-i", "phpldapadmin", "php"], input=script.encode('utf-8'), capture_output=True)
print(res.stdout.decode())
print(res.stderr.decode())
