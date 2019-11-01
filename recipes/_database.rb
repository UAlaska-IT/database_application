# frozen_string_literal: true

tcb = 'database_application'

mariadb_server = node[tcb]['configure_mariadb'] && local_database?
postgresql_server = node[tcb]['configure_postgresql'] && local_database?

mariadb_server_install 'Server' do
  password(lazy { vault_default_secret(node[tcb]['root_pw']) }) if node[tcb]['set_root_pw']
  only_if { mariadb_server }
end

postgresql_server_install 'Server' do
  initdb_locale node[tcb]['postgresql']['locale']
  password(lazy { vault_default_secret(node[tcb]['root_pw']) }) if node[tcb]['set_root_pw']
  only_if { postgresql_server }
end

mariadb_server_configuration 'Configuration' do
  only_if { mariadb_server }
end

postgresql_server_conf 'Configuration' do
  only_if { postgresql_server }
end

mariadb_client_install 'Client' do
  only_if { node[tcb]['configure_mariadb'] }
end

postgresql_client_install 'Client' do
  only_if { node[tcb]['configure_postgresql'] }
end

db_name = node[tcb]['db_name']

mariadb_database db_name do
  only_if { mariadb_server }
end

postgresql_database db_name do
  locale node[tcb]['postgresql']['locale']
  only_if { postgresql_server }
end

user = node[tcb]['user_name']
user_pw = vault_default_secret(node[tcb]['user_pw'])

mariadb_user 'DB User' do
  username user
  password user_pw
  only_if { mariadb_server }
end

postgresql_user 'DB User' do
  create_user user
  password user_pw
  only_if { postgresql_server }
end

mariadb_user 'DB Permissions' do
  username user
  password user_pw
  database_name db_name
  action :grant
  only_if { mariadb_server }
end

postgresql_access 'DB Permissions' do
  access_user user
  access_method 'password'
  access_db db_name
  only_if { postgresql_server }
end
