# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['database']['users'] = {}
default[tcb]['database']['mariadb'] = []
default[tcb]['database']['postgresql'] = []

default[tcb]['database']['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['database']['user_pw']['vault_bag_item'] = 'database'
