mine_interfaces:
  match: '*'
  function:
    mine.send:
      - network.interfaces

mysql:
  match: 'djangocon-db1'
  require:
    mine_interfaces
  sls:
    - foo.db

app:
  match: 'djangocon-web*'
  require:
    - mysql
  sls:
    - foo.app
    - foo.vhost

load_db:
  match: 'djangocon-web1'
  require:
    - app
  sls:
    - foo.loaddata