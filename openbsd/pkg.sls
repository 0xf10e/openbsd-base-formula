{% set mirror = salt['pillar.get']('openbsd:mirror',
    'ftp://ftp.hostserver.de/pub/OpenBSD') %}

/etc/pkg.conf:
  file.managed:
    - contents: "installpath = {{ mirror }}/%c/packages/%a/"
    - user: root
    - group: wheel
    - mode: 644
