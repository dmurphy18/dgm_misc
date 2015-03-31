{% set BUILT_PRODUCT = data.data.bld_product %}
{% set BUILT_LOG = data.data.log %}
{% set BUILT_STATUS = data.data.status %}
{% set BUILT_IDKEY = data.data.idkey %}

{% set BUILT_OS = data.data.grains.os_family %}
{% set BUILT_VER = data.data.grains.osrelease %}
{% set BUILT_PLATFORM = data.data.grains.osarch %}
{% set BUILT_MINION_ID = data.data.grains.id %}

{% set BUILT_FINISH_TIME = data._stamp %}

{% set BLDMGR_LCMINION = salt['pillar.get']('sqldb:lookup:config:bldmgr_local_minion_name','lcminion') %}
{% set BLDMGR_DB_NAME = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_name','bld_machine_logs') %}
{% set BLDMGR_DB_TABLE = salt['pillar.get']('sqldb:lookup:config:bldmgr_db_table','buildlogs') %}


deploy_build_finish_sql:
  local.mysql.query:
    - tgt: lcminion
    - arg:
      - bld_machine_logs
      - |
          UPDATE buildlogs SET build_end="{{ BUILT_FINISH_TIME }}", Status="{{ BUILT_STATUS }}", build_log="{{ BUILT_LOG }}", build_product="{{ BUILT_PRODUCT }}" WHERE idkey={{ BUILT_IDKEY }}


deploy_build_finish_file1:
  local.cp.get_file:
    - tgt: lcminion
    - arg:
      - salt://{{ BUILT_MINION_ID }}{{ BUILT_LOG }}
      - /srv/salt/build_results{{ BUILT_LOG }}
    - kwarg:
        makedirs: True

deploy_build_finish_file2:
  local.cp.get_file:
    - tgt: lcminion
    - arg:
      - salt://{{ BUILT_MINION_ID }}{{ BUILT_PRODUCT }}
      - /srv/salt/build_results{{ BUILT_PRODUCT }}
    - kwarg:
        makedirs: True

