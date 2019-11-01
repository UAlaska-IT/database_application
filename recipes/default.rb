# frozen_string_literal: true

tcb = 'database_application'

# TODO: Gating for server, client
#
include_recipe "#{tcb}::_install"

include_recipe "#{tcb}::_server"

include_recipe "#{tcb}::_client"

include_recipe "#{tcb}::_database"

include_recipe "#{tcb}::_firewall" if configure_firewall?

include_recipe "#{tcb}::_backup" if node[tcb]['configure_backup']
