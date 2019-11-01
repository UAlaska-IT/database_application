# frozen_string_literal: true

tcb = 'database_application'

mariadb_server_install 'Server' do
  password(lazy { vault_default_secret(node[tcb]['server']['root_pw']) }) if node[tcb]['server']['set_root_pw']
  only_if { mariadb_server? }
end

postgresql_server_install 'Server' do
  initdb_locale node[tcb]['postgresql']['locale']
  password(lazy { vault_default_secret(node[tcb]['server']['root_pw']) }) if node[tcb]['server']['set_root_pw']
  only_if { postgresql_server? }
end

mariadb_server_configuration 'Configuration' do
  only_if { mariadb_server? }
end

postgresql_server_conf 'Configuration' do
  only_if { postgresql_server? }
end
