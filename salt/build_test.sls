## the state below work for a simple case to proof the state and script works
# TODO: need to allow for jinja templating to pick up the correct vars to use
# similar to to httpd / apache2 examples, but allow for various platforms
# Solaris 10, 11, RHEL/Centos 5,6,7, Ubuntu/Debian, etc.
# with vars for IP of minion build machine, build script name, etc.
# in order to work around the limitiation of Salt States not really being
# concurrent, the build start on minion and its result shall be event driven in
# order to allow for concurrent builds on different machines, just the build
# start shall be serialized, completion shall be event-driver with a reactor
# dealing with the results to be applied to a web-site, initially a web page
# with a table getting added to or alternatively sqlite and have the page
# redisplay after sql update (possibly the easier case to deal with).  Web
# server shall be nginx (since it tends to be favored at SaltStack).

{% set sql_db_package = salt['pillar.get']('sqldb:lookup:config:sqldb_pkg','') %}
## default setting 

{% set BLDMGR_SCRIPT_VERBOSE = "" %}
{% set BLDMGR_SCRIPT_DEBUG = "" %}
{% set BLDMGR_SCRIPT_LOG = "" %}
{% set BLDMGR_SCRIPT_TAG = "" %}
{% set BLDMGR_SCRIPT_SHAHASH = "" %}
{% set BLDMGR_SCRIPT_BRANCH = "" %}
{% set BLDMGR_SCRIPT_REPO = " -r saltstack/salt " %}
{% set BLDMGR_SCRIPT_EREPO = "" %}
{% set BLDMGR_SCRIPT_USER = "" %}


## verbose handling
{% if salt['pillar.get']('bldmgr:verbose') and salt['pillar.get']('bldmgr:verbose') == 'True' %}
{% set BLDMGR_SCRIPT_VERBOSE = " -v " %}
{% endif %}

## debug handling
{% if salt['pillar.get']('bldmgr:debug') and salt['pillar.get']('bldmgr:debug') == 'True' %}
{% set BLDMGR_SCRIPT_DEBUG = " -d " %}
{% endif %}

## log handling
{% if salt['pillar.get']('bldmgr:log') %}
{% set BLDMGR_SCRIPT_LOG = " -l " ~ salt['pillar.get']('bldmgr:log') ~ " "  %}
{% endif %}

## tag handling
{% if salt['pillar.get']('bldmgr:tag') %}
{% set BLDMGR_SCRIPT_TAG = " -t " ~ salt['pillar.get']('bldmgr:tag') ~ " "  %}
{% endif %}

## log handling
{% if salt['pillar.get']('bldmgr:log') %}
{% set BLDMGR_SCRIPT_LOG = " -l " ~ salt['pillar.get']('bldmgr:log') ~ " "  %}
{% endif %}

## shahash handling
{% if salt['pillar.get']('bldmgr:shahash') %}
{% set BLDMGR_SCRIPT_SHAHASH = " -s " ~ salt['pillar.get']('bldmgr:shahash') ~ " "  %}
{% endif %}

## branch handling
{% if salt['pillar.get']('bldmgr:branch') %}
{% set BLDMGR_SCRIPT_BRANCH = " -b " ~ salt['pillar.get']('bldmgr:branch') ~ " "  %}
{% endif %}

## repo handling
{% if salt['pillar.get']('bldmgr:repo') %}
{% set BLDMGR_SCRIPT_REPO = " -r " ~ salt['pillar.get']('bldmgr:repo') ~ " "  %}
{% endif %}

## erepo handling
{% if salt['pillar.get']('bldmgr:erepo') %}
{% set BLDMGR_SCRIPT_EREPO = " -e " ~ salt['pillar.get']('bldmgr:erepo') ~ " "  %}
{% endif %}

## user handling
{% if salt['pillar.get']('bldmgr:user') %}
{% set BLDMGR_SCRIPT_USER = " -u " ~ salt['pillar.get']('bldmgr:user') ~ " "  %}
{% endif %}

# platform build script handling
{% from "bldmgr/map.jinja" import bldmgr with context %}


run_build_test:
  cmd.run:
    - name: /build_product/{{ bldmgr.platform_bld_script }} {{ BLDMGR_SCRIPT_VERBOSE }} {{ BLDMGR_SCRIPT_DEBUG }} {{ BLDMGR_SCRIPT_LOG }} {{ BLDMGR_SCRIPT_TAG }} {{ BLDMGR_SCRIPT_SHAHASH }} {{ BLDMGR_SCRIPT_BRANCH }} {{ BLDMGR_SCRIPT_REPO }} {{ BLDMGR_SCRIPT_EREPO }} {{ BLDMGR_SCRIPT_USER }}
    - output_loglevel: debug
    - shell: /bin/bash
    - cwd:  /build_product
    - require:
      - file: sync_build_test
#    - stateful: True
#    - watch:
#      - file: bldscript
#
#build_test_changed_something:
#  - name: echo_check
#  - watch:
#    - cmd: run_build_test

sync_build_test:
  file.managed:
    - name: /build_product/{{ bldmgr.platform_bld_script }}
    - source: salt://tools/{{ bldmgr.platform_bld_script }}
    - user: root
    - group: root
    - mode: 755
    - makedirs: True


