# frozen_string_literal: true

tcb = 'database_application'

node[tcb]['database']['mariadb'].each do |db_hash|
  restore_database('mariadb', db_hash)
end

node[tcb]['database']['postgresql'].each do |db_hash|
  restore_database('postgresql', db_hash)
end
