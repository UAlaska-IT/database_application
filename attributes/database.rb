# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_mariadb'] = false
default[tcb]['configure_postgresql'] = false
default[tcb]['db_name'] = nil

default[tcb]['mariadb']['databases'] = []
default[tcb]['postgresql']['databases'] = []

default[tcb]['user_name'] = nil

default[tcb]['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['user_pw']['vault_bag_item'] = 'database'
default[tcb]['user_pw']['vault_item_key'] = 'db_user'
