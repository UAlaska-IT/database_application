# frozen_string_literal: true

tcb = 'database_application'

include_recipe "#{tcb}::_install"

include_recipe "#{tcb}::_database"

include_recipe "#{tcb}::_backup" if node[tcb]['database']['configure_backup']
