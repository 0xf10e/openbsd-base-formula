{% set release = salt['grains.get']('osrelease') %}
{% set rel_nodot = release|replace('.','') %}
include:
    - openbsd.patches.{{ rel_nodot }}
{% from 'openbsd/src.sls' import build_user %}

/usr/obj:
  file.directory:
    - user: root
    - group: wsrc
    - dir_mode: 775
  {# see `file: /usr/src` in `openbsd/src.sls`
    - recurse:
      - user
      - group
      - mode
  #}
reset_persmissions_on_usr_obj:
  cmd.run:
    - name: chown -R {{ build_user }}:wsrc /usr/obj
    - require:
      - cmd: reset_persmissions_on_usr_src
