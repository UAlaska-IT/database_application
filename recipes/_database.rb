# frozen_string_literal: true

tcb = 'database_application'

mariadb_client_install 'Client' do
  only_if { node[tcb]['configure_mariadb'] }
end

postgresql_client_install 'Client' do
  only_if { node[tcb]['configure_postgresql'] }
end

db_name = node[tcb]['db_name']

mariadb_database db_name do
  only_if { mariadb_server? }
end

postgresql_database db_name do
  locale node[tcb]['postgresql']['locale']
  only_if { postgresql_server? }
end

user = node[tcb]['user_name']
user_pw = vault_default_secret(node[tcb]['user_pw'])

mariadb_user 'DB User' do
  username user
  password user_pw
  only_if { mariadb_server? }
end

postgresql_user 'DB User' do
  create_user user
  password user_pw
  only_if { postgresql_server? }
end

mariadb_user 'DB Permissions' do
  username user
  password user_pw
  database_name db_name
  action :grant
  only_if { mariadb_server? }
end

postgresql_access 'DB Permissions' do
  access_user user
  access_method 'password'
  access_db db_name
  only_if { postgresql_server? }
end
