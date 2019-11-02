# frozen_string_literal: true

mariadb_client_install 'Client' do
  only_if { mariadb_server? }
end

postgresql_client_install 'Client' do
  only_if { postgresql_server? }
end
