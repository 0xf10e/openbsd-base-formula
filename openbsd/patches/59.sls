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
        make
    - output_loglevel: quiet
    - cwd: /usr/src
    - user: {{ build_user }}
    - require:
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
        make install
    - user: root
    - output_loglevel: quiet
    - require:
        - cmd: compile_kernel



