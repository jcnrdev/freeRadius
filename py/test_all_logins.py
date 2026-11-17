import urllib.request
import urllib.parse
import http.cookiejar

def test_login(username, password):
    cj = http.cookiejar.CookieJar()
    opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(cj))
    
    # 1. GET login form
    opener.open('http://127.0.0.1:8085/cmd.php?cmd=login_form&server_id=1')
    
    # 2. POST credentials
    data = urllib.parse.urlencode({
        'cmd': 'login',
        'server_id': '1',
        'login': username,
        'login_pass': password,
        'submit': 'Authenticate'
    }).encode('utf-8')
    
    resp = opener.open('http://127.0.0.1:8085/cmd.php', data=data)
    html = resp.read().decode('utf-8', errors='ignore')
    
    if 'cmd=login_form' in resp.geturl() or 'invalid username or password' in html.lower():
        print(f"[BLOQUEADO] Usuario '{username}' com senha invalida: ACESSO NEGADO.")
        return False
    else:
        tree_resp = opener.open('http://127.0.0.1:8085/index.php')
        tree_html = tree_resp.read().decode('utf-8', errors='ignore')
        has_server = 'svroldap-01' in tree_html.lower()
        has_users = 'ou=users' in tree_html.lower()
        has_groups = 'ou=groups' in tree_html.lower()
        print(f"[SUCESSO] Usuario '{username}' autenticado! Servidor: SVROLDAP-01 ({has_server}), ou=users: {has_users}, ou=groups: {has_groups}")
        return True

print("--- Testando Seguranca e Contas de Administrador ---")
test_login('adminjoao', 'L@is@151203.')
test_login('ADMINISTRADOR', 'L@is@151203.')
test_login('cn=admin,dc=empresa,dc=local', '1Uf;HS#%^;i}H=`5Cm{{ds1Gc')
test_login('cn=admin,dc=empresa,dc=local', 'adminSecret123')
test_login('adminjoao', 'SenhaIncorreta')
