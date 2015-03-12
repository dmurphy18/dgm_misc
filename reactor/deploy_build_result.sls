
deploy_build_result:
  local.cmd.run:
    - tgt: cent66dgm-minion
    - arg:
      - cp /build_product/build-test.log /build_product/bld_reactor_fired


