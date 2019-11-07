# frozen_string_literal: true

tcb = 'database_application'

mariadb_client_install 'Client' do
  version node[tcb]['mariadb_version'] if node[tcb]['mariadb_version']
  only_if { mariadb_server? }
end

postgresql_client_install 'Client' do
  version node[tcb]['postgresql_version'] if node[tcb]['postgresql_version']
  only_if { postgresql_server? }
end
