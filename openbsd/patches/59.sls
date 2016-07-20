# Can build patched binaries w/o source:
include:
  - openbsd.src

{% from 'openbsd/src.sls' import build_user, home %}

compile_kernel:
  cmd.run: 
    - name: |
        cd /usr/src/sys/arch/`machine`/conf
        KK=`sysctl -n kern.osversion | cut -d# -f1`
        config $KK
        cd ../compile/$KK
        make > /dev/null
    - output_loglevel: quiet
    - cwd: /usr/src
    - user: {{ build_user }}
    - require:
      - file: /usr/obj
      - cmd: {{ home }}/002_in6bind.patch.sig
      - cmd: {{ home }}/003_pledge.patch.sig
      - cmd: {{ home }}/004_mbuf.patch.sig
      - cmd: {{ home }}/007_uvideo.patch.sig
      - cmd: {{ home }}/008_bnx.patch.sig
      - cmd: {{ home }}/013_splice.patch.sig
      - cmd: {{ home }}/014_unp.patch.sig
      - cmd: {{ home }}/015_dirent.patch.sig
      - cmd: {{ home }}/016_mmap.patch.sig
      - cmd: {{ home }}/017_arp.patch.sig
      - cmd: {{ home }}/018_timeout.patch.sig
      - cmd: {{ home }}/019_kevent.patch.sig
      - cmd: {{ home }}/020_amap.patch.sig

install_kernel:
  cmd.run:
    - name: |
        cd /usr/src/sys/arch/`machine`/conf
        KK=`sysctl -n kern.osversion | cut -d# -f1`
        cd ../compile/$KK
        make install > /dev/null
    - user: root
    - output_loglevel: quiet
    - require:
        - cmd: compile_kernel

compile_patched_crypto:
  cmd.run:
    - name: |
        make obj > /dev/null
        make depend > /dev/null
        make > /dev/null
    - cwd: /usr/src/lib/libcrypto
    - require:
      - file: /usr/obj
      - cmd: {{ home }}/005_crypto.patch.sig
      - cmd: {{ home }}/009_crypto.patch.sig
      - cmd: {{ home }}/011_crypto.patch.sig
      - cmd: {{ home }}/012_crypto.patch.sig

install_patched_crypto:
  cmd.run:
    - name: make install > /dev/null
    - user: root
    - cwd: /usr/src/lib/libcrypto
    - output_loglevel: quiet
    - require:
        - cmd: compile_patched_crypto

{% load_yaml as singles %}
  {{ home }}/001_sshd.patch.sig: /usr/src/usr.bin/ssh
  {{ home }}/006_smtpd.patch.sig: /usr/src/usr.sbin/smtpd
  {{ home }}/010_libexpat.patch.sig: /usr/src/lib/libexpat
{% endload %}

{# TODO: This has to go into a macro: #}
{% for file, dir in singles.items() %}
  {% set subsys = dir.split('/')[-1] %}
compile_patched_{{ subsys }}:
  cmd.run:
    - name: |
        make obj > /dev/null
        make depend > /dev/null
        make > /dev/null
    - cwd: {{ dir }}
    - user: {{ build_user }}
    - group: wsrc
    - require:
      - file: /usr/obj
      - cmd: {{ file }}

install_patched_{{ subsys }}:
  cmd.run:
    - name: make install > /dev/null
    - cwd: {{ dir }}
    - user: root
    - require:
      - cmd: compile_patched_{{ subsys }}
{% endfor %}
