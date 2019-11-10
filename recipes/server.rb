# frozen_string_literal: true

tcb = 'database_application'

service 'postgresql' do
  extend PostgresqlCookbook::Helpers
  service_name(lazy { platform_service_name })
  supports restart: true, status: true, reload: true
  action :nothing
end

include_recipe "#{tcb}::_install"

include_recipe "#{tcb}::_server"

include_recipe "#{tcb}::_database"

include_recipe "#{tcb}::_firewall" if configure_firewall?

include_recipe "#{tcb}::_backup" if node[tcb]['configure_backup']
