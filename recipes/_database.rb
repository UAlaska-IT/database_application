# frozen_string_literal: true

tcb = 'database_application'

node[tcb]['database']['users'].each do |username, user_hash|
  next if username == 'root' # We do not create the root user; password is set during server install

  hosts_for_user('mariadb', user_hash).each do |host|
    mariadb_user "User #{username}@#{host}" do
      username username
      host host
      password(lazy { user_password(username) })
      only_if { mariadb_server? }
    end
  end

  postgresql_user "User #{username}" do
    create_user username
    password(lazy { user_password(username) })
    only_if { postgresql_server? }
  end
end

node[tcb]['database']['mariadb'].each do |db_hash|
  db_name = db_hash['db_name']

  mariadb_database db_name do
    collation node[tcb]['mariadb']['db_collation']
    encoding node[tcb]['mariadb']['db_encoding']
  end

  db_hash['user_names'].each do |username|
    user_hash = node[tcb]['database']['users'][username]
    hosts = hosts_for_user('mariadb', user_hash)

    hosts.each do |host|
      mariadb_user "Permissions for #{username}@#{host} on #{db_name}" do
        username username
        host host
        password(lazy { user_password(username) })
        database_name db_name
        action :grant
      end
    end
  end
end

node[tcb]['database']['postgresql'].each do |db_hash|
  db_name = db_hash['db_name']

  postgresql_database db_name do
    locale node[tcb]['postgresql']['db_locale']
  end

  db_hash['user_names'].each do |username|
    user_hash = node[tcb]['database']['users'][username]
    hosts = hosts_for_user('postgresql', user_hash)

    hosts.each do |host|
      postgresql_access "Permissions for #{username}@#{host} on #{db_name}" do
        source 'pg_hba.conf.erb'
        cookbook 'database_application'
        access_user username
        access_method 'md5'
        access_type 'host'
        access_addr host
        access_db db_name
        notifies :reload, 'service[postgresql]', :delayed
      end
    end
  end
end
