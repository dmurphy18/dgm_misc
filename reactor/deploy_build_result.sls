{% set BUILT_PRODUCT = data.data.bld_product %}
{% set BUILT_LOG = data.data.log %}
{% set BUILT_STATUS = data.data.status %}

{% set BUILT_OS = grains.os_family %}
{% set BUILT_VER = grains.osrelease %}
{% set BUILT_PLATFORM = grains.osarch %}

deploy_build_result:
  local.mysql.query:
    - tgt: lcminion
    - arg:
      - bld_machine_logs
      - 'INSERT INTO buildlogs (OS, Version, Platform, Status, build_log, build_product) VALUES ( "{{ BUILT_OS }}", " {{ BUILT_VER }}", "{{ BUILT_PLATFORM }}", "{{ BUILT_STATUS }}", "{{ BUILT_LOG }}", "{{ BUILT_PRODUCT }}" )'

