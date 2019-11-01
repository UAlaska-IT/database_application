# frozen_string_literal: true

tcb = 'database_application'

mariadb_client_install 'Client' do
  only_if { node[tcb]['configure_mariadb'] }
end

postgresql_client_install 'Client' do
  only_if { node[tcb]['configure_postgresql'] }
end
