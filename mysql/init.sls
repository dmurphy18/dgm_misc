
mysql_setup:
  pkg.installed:
    - name: mysql-server

mysql_service:
  service.running:
    - name: mysqld
    - enable: True
    - require:
      - pkg: mysql_setup

