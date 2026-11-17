# FreeRADIUS Stack - Docker

Stack base para autenticação RADIUS com integração de banco SQL e LDAP:
- **FreeRADIUS 3.2** (autenticação e contabilidade)
- **MariaDB 10.11** (banco de dados do RADIUS)
- **OpenLDAP 1.5** (servidor LDAP corporativo)
- **phpLDAPadmin 0.9** (interface web para gerenciamento do diretório LDAP)

---

## 🚀 Portas e Interfaces Web

| Serviço | URL / Porta | Usuários de Acesso | Senha |
| :--- | :--- | :--- | :--- |
| **phpLDAPadmin (Servidor: SVROLDAP-01)** | `http://<IP_DO_SERVIDOR>:8085/` | `adminjoao`<br>`ADMINISTRADOR`<br>`cn=admin,dc=empresa,dc=local` | `L@is@151203.`<br>`L@is@151203.`<br>`1Uf;HS#%^;i}H=\`5Cm{{ds1Gc` |
| **FreeRADIUS Autenticação** | `Porta UDP 1812` | - | Secret: `testing123` |
| **FreeRADIUS Contabilidade** | `Porta UDP 1813` | - | Secret: `testing123` |
| **OpenLDAP (LDAP / LDAPS)** | `Portas TCP 389 / 636` | `adminjoao` / `ADMINISTRADOR` | `L@is@151203.` |
| **MariaDB (Acesso externo)** | `Porta TCP 3307` | `radius` (ou `root`) | `qHm-Eh65RX48TR_KuZJN_BFz` |

---

## ⚡ Início Rápido e Testes

```bash
# 1. Testar autenticação do administrador geral no FreeRADIUS
docker exec freeradius radtest adminjoao L@is@151203. 127.0.0.1 0 testing123

# 2. Testar autenticação do usuário ADMINISTRADOR
docker exec freeradius radtest ADMINISTRADOR L@is@151203. 127.0.0.1 0 testing123

# 3. Testar autenticação de usuário em subpasta de projetos (ex: PX-TESTE)
docker exec freeradius radtest user.projeto L@is@Projeto123. 127.0.0.1 0 testing123

# 4. Testar autenticação de um usuário padrão LDAP
docker exec freeradius radtest teste.ldap SenhaLdap@2024 127.0.0.1 0 testing123
```

---

## 📁 Estrutura do OpenLDAP (SVROLDAP-01)

- **Base DN**: `dc=empresa,dc=local`
- **OU de Usuários**: `ou=users,dc=empresa,dc=local`
  - `adminjoao` (Administrador Geral com todas as permissões)
  - `ADMINISTRADOR` (Administrador Geral)
  - `teste.ldap` (Usuário de teste)
- **OU de Grupos**: `ou=groups,dc=empresa,dc=local`
  - `cn=admins` (gidNumber: 10002) - Grupo com privilégios totais de gestão (`manage`)
  - `cn=users` (gidNumber: 10000) - Grupo padrão de usuários
  - `cn=wifi-users` (gidNumber: 10001) - Grupo de usuários Wi-Fi
- **Segurança de Acesso**: Protegido por autenticação de sessão. Apenas administradores autorizados com credenciais válidas acessam a gestão do diretório.
