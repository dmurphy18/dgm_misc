
sqldb:
  lookup:
    config:
      sqldb_pkg: mysql-server
      sqldb_service: mysqld
      sqldb_host: localhost
      db_name: bld_machine_logs
      db_table: buildlogs
      db_user: root
      db_pwd: dogkat2015
      db_user_rights: 'all privileges'
      db_charset: utf8

