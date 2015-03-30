
base:
  lcminion:
    - sqldb.sql_db_bldmgr
##    - nginx

  'G@roles:buildbox':
    - match: compound
    - build_test

