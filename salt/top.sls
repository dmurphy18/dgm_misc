
base:
  lcminion:
    - sqldb.sql_db
    - nginx

  'G@roles:buildbox':
    - match: compound
    - build_test

