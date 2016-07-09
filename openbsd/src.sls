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

{% import_yaml 'openbsd/cksums/' + release + '.yaml' as cksums %}

extract_{{ src_tarball|replace('.','_') }}:
    archive.extracted:
        - name: /usr/src
        - source: {{ mirror }}/{{ release }}/{{ src_tarball }}
        - source_hash: sha256={{ cksums[src_tarball] }}
        - tar_options: z
        - archive_format: tar
        - user: {{ build_user }}
        - group: wsrc
        - if_missing: /usr/src/Makefile

extract_sys_tar_gz:
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
            - archive: extract_{{ src_tarball|replace('.','_') }}

{% set home = salt['user.info'](build_user)['home'] %}
{% set applied = [] %}
{# Relying on the filenames being sorted correctly: #}
{% for file in cksums|sort %}
    {% if file.endswith('.patch.sig') %}
{{ home }}/{{ file }}:
    file.managed:
        - source: {{ mirror }}/patches/{{ release }}/common/{{ file }}
        - source_hash: sha256={{ cksums[file] }}
        - user: {{ build_user }}
        - group: wsrc
        {% if applied|length > 0 %}
        - require:
          - file: {{ home }}/{{ applied[-1] }}
          - archive: extract_{{ src_tarball|replace('.','_') }}
          - archive: extract_sys_tar_gz
        {% endif %}
        {% do applied.append(file) %}
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
