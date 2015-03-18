{% set sql_db_name = salt['pillar.get']('sqldb:lookup:config:db_name','') %}
{% set sql_db_table = salt['pillar.get']('sqldb:lookup:config:db_table','')  %}

include:
  - sqldb

mysql_db_check:
  module.run:
    - name: mysql.db_exists
    - m_name: {{ sql_db_name }}
    - require:
      - sls: sqldb

mysql_db_table:
  module.run:
    - name: mysql.query
    - database: {{ sql_db_name }}
    - query: 'CREATE TABLE IF NOT EXISTS {{ sql_db_table }} ( build_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, OS VARCHAR(10) NOT NULL, Version VARCHAR(10) NOT NULL, Platform VARCHAR(10) NOT NULL, Status VARCHAR(10) NOT NULL DEFAULT "ERRORS", build_log VARCHAR(255) NOT NULL, build_product VARCHAR(255) NOT NULL) DEFAULT CHARSET=utf8'
    - require:
      - module: mysql_db_check



