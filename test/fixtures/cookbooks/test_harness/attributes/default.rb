# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_mariadb'] = true
default[tcb]['configure_postgresql'] = true

default[tcb]['db_name'] = 'not_used'
default[tcb]['user_name'] = 'bud'

default[tcb]['root_pw']['vault_bag_item'] = 'database'
default[tcb]['user_pw']['vault_bag_item'] = 'database'
