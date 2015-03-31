{% set sql_bldmgr_db_name = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_name','bld_machine_logs') %}
{% set sql_bldmgr_db_table = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_table','buildlogs')  %}

include:
  - sqldb

mysql_db_bldmgr_check:
  module.run:
    - name: mysql.db_exists
    - m_name: {{ sql_bldmgr_db_name }}
    - require:
      - sls: sqldb


mysql_bldmgr_db_table:
  module.run:
    - name: mysql.query
    - database: {{ sql_bldmgr_db_name }}
    - query: |
               CREATE TABLE IF NOT EXISTS {{ sql_bldmgr_db_table }} ( build_end DATETIME, build_start TIMESTAMP DEFAULT CURRENT_TIMESTAMP, OS VARCHAR(20) NOT NULL, Version VARCHAR(20) NOT NULL, Platform VARCHAR(20) NOT NULL, Status VARCHAR(20) NOT NULL DEFAULT "ERRORS", build_log VARCHAR(255) NOT NULL, build_product VARCHAR(255) NOT NULL, idkey BIGINT NOT NULL) DEFAULT CHARSET=utf8
    - require:
      - module: mysql_db_bldmgr_check


