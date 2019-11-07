# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['database']['users'] = {
  root: {
    vault_item_key: 'db_root',
  },
  bud: {
    additional_hosts: [
      'db.example.com',
    ],
  },
  sri: {},
}

default[tcb]['database']['mariadb'] = [
  {
    db_name: 'secret_db',
    user_names: [
      'sri',
      'bud',
    ],
  },
  {
    db_name: 'small_db',
    user_names: [
      'sri',
    ],
  },
]

default[tcb]['database']['postgresql'] = [
  {
    db_name: 'public_db',
    user_names: [
      'bud',
    ],
  },
  {
    db_name: 'large_db',
    user_names: [
      'bud',
      'sri',
    ],
  },
]

default[tcb]['backup']['directory'] = '/var/backups/test_db'
