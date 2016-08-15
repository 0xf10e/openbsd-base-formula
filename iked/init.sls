/etc/iked.conf:
  file.managed:
    - source: salt://iked/files/iked.conf
    - template: jinja
    - user: root
    - group: wheel
    - mode: 600

check_iked.conf:
  cmd.run:
    - name: iked -nf /etc/iked.conf
    - require:
      - file: /etc/iked.conf
