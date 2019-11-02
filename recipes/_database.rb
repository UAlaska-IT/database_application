# frozen_string_literal: true

tcb = 'database_application'

node[tcb]['database']['users'].each do |username, _|
  user_pw = user_password(username)

  mariadb_user 'DB User' do
    username username
    password user_pw
    only_if { mariadb_server? }
  end

  postgresql_user 'DB User' do
    create_user username
    password user_pw
    only_if { postgresql_server? }
  end
end

node[tcb]['database']['mariadb'].each do |db_hash|
  db_name = db_hash['db_name']

  mariadb_database db_name do
    only_if { mariadb_server? }
  end

  db_hash['user_names'].each do |username|
    mariadb_user 'DB Permissions' do
      username username
      password user_password(username)
      database_name db_name
      action :grant
      only_if { mariadb_server? }
    end
  end
end

node[tcb]['database']['mariadb'].each do |db_hash|
  db_name = db_hash['db_name']

  postgresql_database db_name do
    locale node[tcb]['postgresql']['locale']
    only_if { postgresql_server? }
  end

  db_hash['user_names'].each do |username|
    postgresql_access 'DB Permissions' do
      access_user username
      access_method 'password'
      access_db db_name
      only_if { postgresql_server? }
    end
  end
end
