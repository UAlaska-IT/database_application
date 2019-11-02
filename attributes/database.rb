# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_mariadb'] = false
default[tcb]['configure_postgresql'] = false
default[tcb]['db_name'] = nil
default[tcb]['user_name'] = nil

default[tcb]['database']['users'] = {}
default[tcb]['database']['mariadb'] = []
default[tcb]['database']['postgresql'] = []

default[tcb]['database']['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['database']['user_pw']['vault_bag_item'] = 'database'
