{% for key in salt['pillar.get']('openbsd:signify_keys', []) %}
  {% if key.startswith('/') %}
{{ key }}:
  {% else %}
/etc/signify/{{ key }}
  {% endif %}
  file.managed:
    - user: root
    - group: wheel
    - mode: 444
    - contents_pillar: openbsd:signify_keys:{{ key }}
{% endfor %}
