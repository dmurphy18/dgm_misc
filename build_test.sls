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


run_build_test:
  cmd.run:
    - name: /build_product/bldscript
    - stateful: True
    - output_loglevel: debug
    - shell: /bin/bash
    - cwd:  /build_product
    - require:
      - file: sync_build_test
#    - watch:
#      - file: bldscript

#build_test_changed_something:
#    - name: echo_check
#    - watch:
#      - cmd: run_build_test

sync_build_test:
  file.managed:
    - name: /build_product/bldscript
    - source: salt://tools/bldscript
    - user: root
    - group: root
    - mode: 755
    - makedirs: True


