
include:
  - mysql

mysql_db_check:
  module.run:
    - name: mysql.db_exists
    - m_name: 'bld_machine_logs'
    - require:
      - sls: mysql



