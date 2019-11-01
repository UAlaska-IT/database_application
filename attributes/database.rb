# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_mariadb'] = false
default[tcb]['configure_postgresql'] = false
default[tcb]['db_name'] = nil

default[tcb]['mariadb']['databases'] = []
default[tcb]['postgresql']['databases'] = []

default[tcb]['postgresql']['locale'] = 'C.UTF-8'

default[tcb]['host'] = 'localhost'
default[tcb]['user_name'] = nil

default[tcb]['set_root_pw'] = true
default[tcb]['root_pw']['vault_data_bag'] = 'passwords'
default[tcb]['root_pw']['vault_bag_item'] = nil
default[tcb]['root_pw']['vault_item_key'] = 'db_root'

default[tcb]['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['user_pw']['vault_bag_item'] = nil
default[tcb]['user_pw']['vault_item_key'] = 'db_user'
