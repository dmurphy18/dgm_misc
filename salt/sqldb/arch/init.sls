{% set sql_db_package = salt['pillar.get']('sqldb:lookup:config:sqldb_pkg','') %}
{% set sql_db_service = salt['pillar.get']('sqldb:lookup:config:sqldb_service','') %}
{% set sql_db_host = salt['pillar.get']('sqldb:lookup:config:sqldb_host','localhost') %}

{% set sql_db_name = salt['pillar.get']('sqldb:lookup:config:db_name','') %}
{% set sql_db_user = salt['pillar.get']('sqldb:lookup:config:db_user', 'root')  %}
{% set sql_db_pwd = salt['pillar.get']('sqldb:lookup:config:db_pwd', '')  %}
{% set sql_db_charset = salt['pillar.get']('sqldb:lookup:config:db_charset', 'utf8')  %}
{% set sql_db_user_rights = salt['pillar.get']('sqldb:lookup:config:db_user_rights', 'all privileges')  %}

sql_setup:
  pkg.installed:
    - name: {{ sql_db_package }}

sql_service:
  service.running:
    - name: {{ sql_db_service }}
    - enable: True
    - require:
      - pkg: sql_setup

bldmlogs_db:
  mysql_database.present:
    - name: {{ sql_db_name }}
    - require:
      - service: sql_service

bldmlogs_db_user:
  mysql_user.present:
    - host: {{ sql_db_name }}
    - password: {{ sql_db_pwd }}
    - connection_user: {{ sql_db_user }}
    - connection_pass: {{ sql_db_pwd }}
    - connection_charset: {{ sql_db_charset }}
    - saltenv:
      - LC_ALL: "en_US.utf8"
    - require:
      - mysql_database: bldmlogs_db

bldmlogs_db_grants:
  mysql_grants.present:
    - grant: {{ sql_db_user_rights }}
    - database: '{{ sql_db_name }}.*'
    - host: {{ sql_db_host }}
    - user: {{ sql_db_user }}
    - require:
      - mysql_user: bldmlogs_db_user

