<?php
/** NOTE **
 ** Make sure that <?php is the FIRST line of this file!
 ** IE: There should NOT be any blank lines or spaces BEFORE <?php
 **/

/*********************************************
 * Useful important configuration overrides  *
 *********************************************/

$config->custom->debug['level'] = 0;
$config->custom->debug['syslog'] = true;
$config->custom->jpeg['tmpdir'] = '/var/www/tmp';
$config->custom->session['blowfish'] = 'W m5,6((Z_]JaYX_I@YL8/7]^(SN0@ARn182JM{s,?czq8pW}awzn?F FuA <d8*';

/*********************************************
 * Appearance                                *
 *********************************************/
$config->custom->appearance['hide_template_warning'] = true;

/*********************************************
 * User-friendly attribute translation       *
 *********************************************/
$config->custom->appearance['friendly_attrs'] = array(
    'facsimileTelephoneNumber' => 'Fax',
    'gid'                      => 'Group',
    'mail'                     => 'Email',
    'telephoneNumber'          => 'Telephone',
    'uid'                      => 'User Name',
    'userPassword'             => 'Password'
);

/*********************************************
 * Define your LDAP servers in this section  *
 *********************************************/
$servers = new Datastore();
$servers->newServer('ldap_pla');
$servers->setValue('server','name','SVROLDAP-01');
$servers->setValue('server','host','openldap');
// A raiz do diretório deve ser apenas a base principal do LDAP.
// Isso permite que o phpLDAPadmin mostre a árvore inteira sem bloquear
// a navegação para users, groups e PROJETOS.
$servers->setValue('server','base', array(
    'dc=empresa,dc=local'
));

$servers->setValue('login','auth_type','session');
$servers->setValue('login','bind_id','cn=admin,dc=empresa,dc=local');
$servers->setValue('login','bind_pass','adminSecret123');
$servers->setValue('login','attr','uid');
$servers->setValue('login','fallback_dn',true);
$servers->setValue('appearance','open_tree',true);
$servers->setValue('appearance','show_create',true);

