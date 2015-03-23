{% set BUILT_PRODUCT = data.data.bld_product %}
{% set BUILT_LOG = data.data.log %}
{% set BUILT_STATUS = data.data.status %}

{% set BUILT_OS = data.data.grains.os_family %}
{% set BUILT_VER = data.data.grains.osrelease %}
{% set BUILT_PLATFORM = data.data.grains.osarch %}
{% set BUILT_MINION_ID = data.data.grains.id %}

deploy_build_result_sql:
  local.mysql.query:
    - tgt: lcminion
    - arg:
      - bld_machine_logs
      - 'INSERT INTO buildlogs (OS, Version, Platform, Status, build_log, build_product) VALUES ( "{{ BUILT_OS }}", " {{ BUILT_VER }}", "{{ BUILT_PLATFORM }}", "{{ BUILT_STATUS }}", "{{ BUILT_LOG }}", "{{ BUILT_PRODUCT }}" )'

deploy_build_result_file1:
  local.cp.get_file:
    - tgt: lcminion
    - arg:
      - salt://{{ BUILT_MINION_ID }}{{ BUILT_LOG }}
      - /srv/salt/build_results{{ BUILT_LOG }}
    - kwarg:
        makedirs: True

deploy_build_result_file2:
  local.cp.get_file:
    - tgt: lcminion
    - arg:
      - salt://{{ BUILT_MINION_ID }}{{ BUILT_PRODUCT }}
      - /srv/salt/build_results{{ BUILT_PRODUCT }}
    - kwarg:
        makedirs: True
