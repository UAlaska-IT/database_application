# frozen_string_literal: true

tcb = 'database_application'

mariadb_server_install 'Server' do
  password(lazy { user_password('root') }) if set_root_password?
  version node[tcb]['mariadb_version'] if node[tcb]['mariadb_version']
  only_if { mariadb_server? }
end

psql_ver = node[tcb]['postgresql_version']

postgresql_server_install 'Server' do
  initdb_locale node[tcb]['postgresql']['locale']
  password(lazy { user_password('root') }) if set_root_password?
  version psql_ver if psql_ver
  only_if { postgresql_server? }
end

code = <<~CODE
  systemctl restart mariadb
CODE

bash 'Initialize MariaDB' do
  code code
  action :nothing
  subscribes :run, 'mariadb_server_install[Server]', :immediate
  only_if { platform_family?('rhel') }
end

code = <<~CODE
  /usr/pgsql-#{psql_ver}/bin/postgresql-#{psql_ver}-setup initdb
  /usr/pgsql-#{psql_ver}/bin/postgresql-#{psql_ver}-setup upgrade
  systemctl restart postgresql-#{psql_ver}
CODE

bash 'Initialize PostgreSQL' do
  code code
  action :nothing
  subscribes :run, 'postgresql_server_install[Server]', :immediate
  only_if { platform_family?('rhel') }
end

mariadb_server_configuration 'Configuration' do
  version node[tcb]['mariadb_version'] if node[tcb]['mariadb_version']
  only_if { mariadb_server? }
end

postgresql_server_conf 'Configuration' do
  version node[tcb]['postgresql_version'] if node[tcb]['postgresql_version']
  only_if { postgresql_server? }
end
