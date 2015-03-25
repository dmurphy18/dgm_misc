
sqldb:
  lookup:
    config:
      sqldb_pkg: mysql-server
      sqldb_service: mysqld
      sqldb_host: localhost
      sqldb_port: 3306
      db_user: saltadmin
      db_pwd: saltadmin
      db_user_rights: 'all privileges'
      db_charset: utf8
      bldmgr_db_name: bld_machine_logs
      bldmgr_db_table: buildlogs
      bldmgr_local_minion_name: lcminion

### jobcache_db_name: salt
