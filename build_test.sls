
run_build_test:
  cmd.run:
    - name: /root/tools/bldscript
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
    - name: /root/tools/bldscript
    - source: salt://tools/bldscript
    - user: root
    - group: root
    - mode: 755
    - makedirs: True


