include:
    - openbsd.patches

{# Iterate over users to find the 1st on in group wsrc? #}
{% set build_user = salt['pillar.get']('openbsd:build_user') %}
{% set mirror = salt['pillar.get']('openbsd:mirror', 
    'ftp://ftp.hostserver.de/pub/OpenBSD') %}

{% set release = salt['grains.get']('osrelease') %}
{% set rel_nodot = release|replace('.','') %}
{% if release == '5.8' %}
  {% set src_tarball = 'cd-src.tar.gz' %}
{% else %}
  {% set src_tarball = 'src.tar.gz' %}
{% endif %}

{% load_yaml 'openbsd/cksums/' + release + '.yaml' as cksums %}

/usr/src:
    archive.extracted:
        - source: {{ mirror }}/{{ release }}/{{ src_tarball }}
        - source_hash: sha256={{ cksums[src_tarball] }}
        - tar_options: z
        - archive_format: tar
        - user: {{ build_user }}
        - group: wsrc
        - if_missing: /usr/src/Makefile

/usr/src/sys:
    archive.extracted:
        # Has to be extracted in /usr/src:
        - name: /usr/src
        - source: {{ mirror }}/{{ release }}/sys.tar.gz
        - source_hash: sha256={{ cksums['sys.tar.gz'] }}
        - tar_options: z
        - archive_format: tar
        - user: {{ build_user }}
        - group: wsrc
        - if_missing: /usr/src/sys/Makefile
        - require: 
            - archive: /usr/src

{% set home = salt['user.info'](build_user)['home'] %}
{# Relying on the filenames being sorted correctly: #}
{% set prev_file = False %}
{% for file in cksums|sort %}
    {% if file.endswith('.patch.sig') %}
{{ home }}/{{ file }}:
    file.managed:
        - source: {{ mirror }}/patches/{{ release }}/common/{{ file }}
        - source_hash: sha256={{ chksums[file] }}
        - user: {{ build_user }}
        - group: wsrc
        {% if prev_file %}
        - require:
            file: {{ home }}/{{ prev_file }}
        {% endif %}
        {% do prev_file = file %}
    cmd.run:
        - name: |
            signify -Vep /etc/signify/openbsd-{{ rel_nodot }}-base.pub \
            -x {{ file }} -m - | (cd /usr/src && patch -p0)
        - cwd: {{ home }}
        - user: {{ build_user }}
        - require:
            - file: {{ home }}/{{ file }}
    {# else: pass #}
    {% endif %}
{% endfor %}
