# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['host'] = 'localhost'

default[tcb]['server']['set_root_pw'] = true
default[tcb]['server']['root_pw']['vault_data_bag'] = 'passwords'
default[tcb]['server']['root_pw']['vault_bag_item'] = 'database'
default[tcb]['server']['root_pw']['vault_item_key'] = 'db_root'

default[tcb]['postgresql']['locale'] = 'C.UTF-8'
