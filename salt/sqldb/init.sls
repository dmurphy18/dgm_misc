{% set sql_db_package = salt['pillar.get']('sqldb:lookup:config:sqldb_pkg','') %}
{% set sql_db_service = salt['pillar.get']('sqldb:lookup:config:sqldb_service','') %}
{% set sql_db_host = salt['pillar.get']('sqldb:lookup:config:sqldb_host','localhost') %}
{% set sql_db_port = salt['pillar.get']('sqldb:lookup:config:sqldb_port',3306) %}

{% set sql_db_charset = salt['pillar.get']('sqldb:lookup:config:db_charset', 'utf8')  %}
{% set sql_db_user_rights = salt['pillar.get']('sqldb:lookup:config:db_user_rights', 'all privileges')  %}
{% set sql_db_user = salt['pillar.get']('sqldb:lookup:config:db_user', 'saltadmin')  %}
{% set sql_db_pwd = salt['pillar.get']('sqldb:lookup:config:db_pwd', 'saltadmin')  %}

{% set sql_db_name = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_name','bld_machine_logs') %}

sql_setup:
  pkg.installed:
    - name: {{ sql_db_package }}

sql_service:
  service.running:
    - name: {{ sql_db_service }}
    - enable: True
    - require:
      - pkg: sql_setup

sql_db_exists:
  mysql_database.present:
    - name: {{ sql_db_name }}
    - kwargs:
        connection_host: {{ sql_db_host }}
        connection_port: {{ sql_db_port }}
        connection_user: {{ sql_db_user }}
        connection_pass: {{ sql_db_pwd }}
        connection_db: {{ sql_db_name }}
    - require:
      - service: sql_service


sql_db_user_exists:
  mysql_user.present:
    - name: {{ sql_db_user }}
    - host: {{ sql_db_host }}
    - password: {{ sql_db_pwd }}
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - kwargs:
        connection_host: {{ sql_db_host }}
        connection_port: {{ sql_db_port }}
        connection_user: {{ sql_db_user }}
        connection_pass: {{ sql_db_pwd }}
        connection_db: {{ sql_db_name }}
    - require:
      - mysql_database: sql_db_exists

sql_db_grants_setup:
  mysql_grants.present:
    - name: {{ sql_db_name }}
    - grant: {{ sql_db_user_rights }}
    - database: {{ sql_db_name }}.*
    - host: {{ sql_db_host }}
    - user: {{ sql_db_user }}
    - kwargs:
        connection_host: {{ sql_db_host }}
        connection_port: {{ sql_db_port }}
        connection_user: {{ sql_db_user }}
        connection_pass: {{ sql_db_pwd }}
        connection_db: {{ sql_db_name }}
    - require:
      - mysql_user: sql_db_user_exists



