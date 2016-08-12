{% set mirror = salt['pillar.get']('openbsd:mirror',
    'ftp://ftp.hostserver.de/pub/OpenBSD/') %}
{% set installpaths = salt['pillar.get']('openbsd:installpath', False) %}

/etc/pkg.conf:
  file.managed:
{% if installpaths %}
    - contents: |
  {%- for path in installpaths %}
        installpath += {{ path }}
  {%- endfor %}
{% else %}
    - contents: installpath = {{ mirror }}/%c/packages/%a
{% endif %}
    - user: root
    - group: wheel
    - mode: 644
