{% set release = salt['grains.get']('osrelease') %}
{% set rel_nodot = release|replace('.','') %}
include:
    - openbsd.patches.{{ rel_nodot }}
