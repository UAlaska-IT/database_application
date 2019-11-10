# frozen_string_literal: true

tcb = 'database_application'

[
  'mariadb',
  'postgresql',
].each do |db_type|
  db_to_restore = node[tcb]['restore']['database'][db_type] || node[tcb]['database'][db_type]

  db_to_restore.each do |db_hash|
    restore_database(db_type, db_hash)
  end
end
