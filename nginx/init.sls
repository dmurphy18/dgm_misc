
nginx_install:
  pkg.installed:
    - name: nginx
    - failhard: True

nginx_service:
  service.running:
    - name: nginx
    - require:
      - pkg: nginx_install
    - watch:
      - file: nginx_conf
      - file: nginx_default_conf

nginx_conf:
  file:
    - managed
    - source: salt://nginx/nginx.conf
    - name: /etc/nginx/nginx.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True

nginx_default_conf:
  file:
    - managed
    - source: salt://nginx/default.conf
    - name: /etc/nginx/conf.d/default.conf
    - user: root
    - group: root
    - mode: 644
    - makedirs: True


