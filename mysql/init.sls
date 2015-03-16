
mysql_setup:
  pkg.installed:
    - name: mysql-server

mysql_service:
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - pkg: mysql_setup

bldmlogs_db:
  mysql_database.present:
    - name: bld_machine_logs
    - require:
      - service: mysql_service

bldmlogs_db_user:
  mysql_user.present:
    - host: localhost
    - password: dogkat2015
    - connection_user: root
    - connection_pass: dogkat2015
    - connection_charset: utf8
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - mysql_database: bldmlogs_db

bldmlogs_db_grants:
  mysql_grants.present:
    - grant: all privileges
    - database: bld_machine_logs.*
    - host: localhost
    - user: root
    - require:
      - mysql_user: bldmlogs_db_user


