# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['database']['configure_mariadb'] = true
default[tcb]['database']['configure_postgresql'] = true

default[tcb]['database']['db_name'] = 'not_used'
default[tcb]['database']['user_name'] = 'bud'

default[tcb]['database']['root_pw']['vault_bag_item'] = 'database'
default[tcb]['database']['user_pw']['vault_bag_item'] = 'database'
