# frozen_string_literal: true

tcb = 'database_application'

node[tcb]['database']['users'].each do |username, user_hash|
  next if username == 'root' # We do not create the root user; password is set during server install

  hosts_for_user(user_hash).each do |host|
    mariadb_user username do
      username username
      host host
      password(lazy { user_password(username) })
      only_if { mariadb_server? }
    end
  end

  postgresql_user username do
    create_user username
    password(lazy { user_password(username) })
    only_if { postgresql_server? }
  end
end

node[tcb]['database']['mariadb'].each do |db_hash|
  db_name = db_hash['db_name']

  mariadb_database db_name do
    only_if { mariadb_server? }
  end

  db_hash['user_names'].each do |username|
    user_hash = node[tcb]['database']['users'][username]
    hosts = hosts_for_user(user_hash)

    hosts.each do |host|
      mariadb_user 'DB Permissions' do
        username username
        host host
        password(lazy { user_password(username) })
        database_name db_name
        action :grant
        only_if { mariadb_server? }
      end
    end
  end
end

node[tcb]['database']['postgresql'].each do |db_hash|
  db_name = db_hash['db_name']

  postgresql_database db_name do
    locale node[tcb]['postgresql']['locale']
    only_if { postgresql_server? }
  end

  db_hash['user_names'].each do |username|
    postgresql_access 'DB Permissions' do
      access_user username
      access_method 'md5'
      access_db db_name
      access_type 'host'
      only_if { postgresql_server? }
    end
  end
end
