{% set release = salt['grains.get']('osrelease') %}
{% set rel_nodot = release|replace('.','') %}
include:
    - openbsd.patches.{{ rel_nodot }}

/usr/obj:
  file.directory:
    - user: root
    - group: wsrc
    - dir_mode: 775
    - recurse:
      - user
      - group
      - mode
