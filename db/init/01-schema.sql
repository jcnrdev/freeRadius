-- ============================================================
--  FreeRADIUS Schema para MariaDB
--  Baseado no schema oficial FreeRADIUS 3.x
--  Executado automaticamente na inicializacao do container db
-- ============================================================

SET NAMES utf8;
SET time_zone = '+00:00';

-- Tabela de verificacao de credenciais
CREATE TABLE IF NOT EXISTS radcheck (
  id           INT(11)      NOT NULL AUTO_INCREMENT,
  username     VARCHAR(64)  NOT NULL DEFAULT '',
  attribute    VARCHAR(64)  NOT NULL DEFAULT '',
  op           CHAR(2)      NOT NULL DEFAULT '==',
  value        VARCHAR(253) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY username (username(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de atributos de resposta por usuario
CREATE TABLE IF NOT EXISTS radreply (
  id           INT(11)      NOT NULL AUTO_INCREMENT,
  username     VARCHAR(64)  NOT NULL DEFAULT '',
  attribute    VARCHAR(64)  NOT NULL DEFAULT '',
  op           CHAR(2)      NOT NULL DEFAULT '=',
  value        VARCHAR(253) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY username (username(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de verificacao de credenciais por grupo
CREATE TABLE IF NOT EXISTS radgroupcheck (
  id           INT(11)      NOT NULL AUTO_INCREMENT,
  groupname    VARCHAR(64)  NOT NULL DEFAULT '',
  attribute    VARCHAR(64)  NOT NULL DEFAULT '',
  op           CHAR(2)      NOT NULL DEFAULT '==',
  value        VARCHAR(253) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY groupname (groupname(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de atributos de resposta por grupo
CREATE TABLE IF NOT EXISTS radgroupreply (
  id           INT(11)      NOT NULL AUTO_INCREMENT,
  groupname    VARCHAR(64)  NOT NULL DEFAULT '',
  attribute    VARCHAR(64)  NOT NULL DEFAULT '',
  op           CHAR(2)      NOT NULL DEFAULT '=',
  value        VARCHAR(253) NOT NULL DEFAULT '',
  PRIMARY KEY (id),
  KEY groupname (groupname(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Associacao usuario <-> grupo
CREATE TABLE IF NOT EXISTS radusergroup (
  id           INT(11)      NOT NULL AUTO_INCREMENT,
  username     VARCHAR(64)  NOT NULL DEFAULT '',
  groupname    VARCHAR(64)  NOT NULL DEFAULT '',
  priority     INT(11)      NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  KEY username (username(32))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de accounting (sessoes)
CREATE TABLE IF NOT EXISTS radacct (
  radacctid          BIGINT(21)   NOT NULL AUTO_INCREMENT,
  acctsessionid      VARCHAR(64)  NOT NULL DEFAULT '',
  acctuniqueid       VARCHAR(32)  NOT NULL DEFAULT '',
  username           VARCHAR(64)  NOT NULL DEFAULT '',
  groupname          VARCHAR(64)  NOT NULL DEFAULT '',
  realm              VARCHAR(64)  NOT NULL DEFAULT '',
  nasipaddress       VARCHAR(15)  NOT NULL DEFAULT '',
  nasportid          VARCHAR(15)  DEFAULT NULL,
  nasporttype        VARCHAR(32)  DEFAULT NULL,
  acctstarttime      DATETIME     DEFAULT NULL,
  acctupdatetime     DATETIME     DEFAULT NULL,
  acctstoptime       DATETIME     DEFAULT NULL,
  acctinterval       INT(12)      DEFAULT NULL,
  acctsessiontime    INT(12)      UNSIGNED DEFAULT NULL,
  acctauthentic      VARCHAR(32)  DEFAULT NULL,
  connectinfo_start  VARCHAR(50)  DEFAULT NULL,
  connectinfo_stop   VARCHAR(50)  DEFAULT NULL,
  acctinputoctets    BIGINT(20)   DEFAULT NULL,
  acctoutputoctets   BIGINT(20)   DEFAULT NULL,
  calledstationid    VARCHAR(50)  NOT NULL DEFAULT '',
  callingstationid   VARCHAR(50)  NOT NULL DEFAULT '',
  acctterminatecause VARCHAR(32)  NOT NULL DEFAULT '',
  servicetype        VARCHAR(32)  DEFAULT NULL,
  framedprotocol     VARCHAR(32)  DEFAULT NULL,
  framedipaddress    VARCHAR(15)  NOT NULL DEFAULT '',
  framedipv6address  VARCHAR(45)  NOT NULL DEFAULT '',
  framedipv6prefix   VARCHAR(45)  NOT NULL DEFAULT '',
  framedinterfaceid  VARCHAR(44)  NOT NULL DEFAULT '',
  delegatedipv6prefix VARCHAR(45) NOT NULL DEFAULT '',
  acctstartdelay     INT(12)      DEFAULT NULL,
  acctstopdelay      INT(12)      DEFAULT NULL,
  xascendsessionsvrkey VARCHAR(10) DEFAULT NULL,
  PRIMARY KEY (radacctid),
  UNIQUE KEY acctuniqueid (acctuniqueid),
  KEY username        (username),
  KEY framedipaddress (framedipaddress),
  KEY acctsessionid   (acctsessionid),
  KEY acctsessiontime (acctsessiontime),
  KEY acctstarttime   (acctstarttime),
  KEY acctinterval    (acctinterval),
  KEY acctstoptime    (acctstoptime),
  KEY nasipaddress    (nasipaddress)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de NAS (clientes RADIUS)
CREATE TABLE IF NOT EXISTS nas (
  id           INT(10)      NOT NULL AUTO_INCREMENT,
  nasname      VARCHAR(128) NOT NULL,
  shortname    VARCHAR(32)  DEFAULT NULL,
  type         VARCHAR(30)  DEFAULT 'other',
  ports        INT(5)       DEFAULT NULL,
  secret       VARCHAR(60)  NOT NULL DEFAULT 'secret',
  server       VARCHAR(64)  DEFAULT NULL,
  community    VARCHAR(50)  DEFAULT NULL,
  description  VARCHAR(200) DEFAULT 'RADIUS Client',
  PRIMARY KEY (id),
  KEY nasname (nasname)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Tabela de post-autenticacao (log de acessos)
CREATE TABLE IF NOT EXISTS radpostauth (
  id          INT(11)      NOT NULL AUTO_INCREMENT,
  username    VARCHAR(64)  NOT NULL DEFAULT '',
  pass        VARCHAR(64)  NOT NULL DEFAULT '',
  reply       VARCHAR(32)  NOT NULL DEFAULT '',
  calledstationid VARCHAR(50) NOT NULL DEFAULT '',
  callingstationid VARCHAR(50) NOT NULL DEFAULT '',
  authdate    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  class       VARCHAR(64)  DEFAULT NULL,
  PRIMARY KEY (id),
  KEY username  (username),
  KEY authdate  (authdate)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── Dados iniciais de exemplo ───────────────────────────────────────────────

-- Usuario admin de teste (senha: admin123 em texto claro - MD5 em producao!)
INSERT IGNORE INTO radcheck (username, attribute, op, value)
VALUES ('testuser', 'Cleartext-Password', ':=', 'testpass123');

-- Associacao usuario e grupo
INSERT IGNORE INTO radusergroup (username, groupname, priority)
VALUES ('testuser', 'users', 1);

-- NAS local para testes
INSERT IGNORE INTO nas (nasname, shortname, type, secret, description)
VALUES ('127.0.0.1', 'localhost', 'other', 'testing123', 'Localhost test NAS');

INSERT IGNORE INTO nas (nasname, shortname, type, secret, description)
VALUES ('172.20.0.0/24', 'docker-net', 'other', 'testing123', 'Docker internal network');
