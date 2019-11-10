# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['mariadb']['db_collation'] = 'utf8_general_ci'
default[tcb]['mariadb']['db_encoding'] = 'utf8'

default[tcb]['postgresql']['db_locale'] =
  if platform_family?('debian')
    'C.UTF-8'
  else
    'en_US.UTF-8'
  end

default[tcb]['database']['users'] = {}
default[tcb]['database']['mariadb'] = []
default[tcb]['database']['postgresql'] = []

default[tcb]['database']['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['database']['user_pw']['vault_bag_item'] = 'database'
