# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['host'] = 'localhost'

default[tcb]['set_root_pw'] = true
default[tcb]['root_pw']['vault_data_bag'] = 'passwords'
default[tcb]['root_pw']['vault_bag_item'] = nil
default[tcb]['root_pw']['vault_item_key'] = 'db_root'

default[tcb]['postgresql']['locale'] = 'C.UTF-8'
