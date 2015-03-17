
include:
  - mysql

mysql_db_check:
  module.run:
    - name: mysql.db_exists
    - m_name: 'bld_machine_logs'
    - require:
      - sls: mysql

mysql_db_table:
  module.run:
    - name: mysql.query
    - database: bld_machine_logs
    - query: 'CREATE TABLE IF NOT EXISTS buildlogs ( build_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, OS VARCHAR(10) NOT NULL, Version VARCHAR(10) NOT NULL, Platform VARCHAR(10) NOT NULL, Status VARCHAR(10) NOT NULL DEFAULT "ERRORS", build_log VARCHAR(255) NOT NULL, build_product VARCHAR(255) NOT NULL) DEFAULT CHARSET=utf8'
    - require:
      - module: mysql_db_check



