{% set BUILT_PRODUCT = data.data.bld_product %}
{% set BUILT_LOG = data.data.log %}
{% set BUILT_STATUS = data.data.status %}
{% set BUILT_IDKEY = data.data.idkey %}

{% set BUILT_OS = data.data.grains.os_family %}
{% set BUILT_VER = data.data.grains.osrelease %}
{% set BUILT_PLATFORM = data.data.grains.osarch %}
{% set BUILT_MINION_ID = data.data.grains.id %}

{% set BLDMGR_LCMINION = salt['pillar.get']('sqldb:lookup:config:bldmgr_local_minion_name','lcminion') %}
{% set BLDMGR_DB_NAME = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_name','lcminion') %}
{% set BLDMGR_DB_TABLE = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_table','lcminion') %}


deploy_build_start_sql:
  local.mysql.query:
    - tgt: {{ BLDMGR_LCMINION }}
    - arg:
      - {{ BLDMGR_DB_NAME }}
      - 'INSERT INTO {{ BLDMGR_DB_TABLE }} (OS, Version, Platform, Status, build_log, build_product, idkey) VALUES ( "{{ BUILT_OS }}", " {{ BUILT_VER }}", "{{ BUILT_PLATFORM }}", "{{ BUILT_STATUS }}", "{{ BUILT_LOG }}", "{{ BUILT_PRODUCT }}" , "{{ BUILT_IDKEY }}" )'

