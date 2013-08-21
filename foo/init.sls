# https://github.com/terminalmage/djangocon2013-sls.git

{% set foo_venv = '/var/www/foo' %}
{% set foo_proj = foo_venv ~ '/django-tutorial' %}
{% set foo_settings = 'foo.settings' %}

include:
  - git
  - pip
  - ssh.server
  - virtualenv

github.com:
  ssh_known_hosts:
    - present
    - user: root
    - fingerprint: 16:27:ac:a5:76:28:2d:36:63:1b:56:4d:eb:df:a6:48
    - require:
      - pkg: ssh_server

foo_venv:
  virtualenv:
    - managed
    - name: {{ foo_venv }}
    - require:
      - pkg: virtualenv

foo:
  git.latest:
    - name: https://github.com/terminalmage/django-tutorial.git
    - target: {{ foo_proj }}
    - force: True
    - require:
      - pkg: git
      - ssh_known_hosts: github.com
    - watch_in:
      - module: foo_syncdb
      - module: foo_collectstatic

foo_pkgs:
  pip:
    - installed
    - bin_env: {{ foo_venv }}
    - requirements: {{ foo_proj }}/requirements.txt
    - require:
      - git: foo
      - pkg: pip
      - virtualenv: foo_venv

foo_settings:
  file:
    - managed
    - name: {{ foo_proj }}/settings.py
    - source: salt://foo/settings.py
    - template: jinja

foo_syncdb:
  module:
    - wait
    - name: django.syncdb {{ foo_settings }}

foo_collectstatic:
  module:
    - wait
    - name: django.collectstatic {{ foo_settings }}
