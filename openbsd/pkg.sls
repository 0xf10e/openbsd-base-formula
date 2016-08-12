/etc/pkg.conf:
  file.managed:
    - contents: |
{% for mirror in salt['pillar.get']('openbsd:mirror',
    ['ftp://ftp.hostserver.de/pub/OpenBSD']) %}
        installpath += {{ mirror }}
{% endfor %}
    - user: root
    - group: wheel
    - mode: 644
