# frozen_string_literal: true

tcb = 'lampp_platform'

default[tcb]['database']['configure_mariadb'] = false
default[tcb]['database']['configure_postgresql'] = false
default[tcb]['database']['db_name'] = nil

default[tcb]['database']['postgresql']['locale'] = 'C.UTF-8'

default[tcb]['database']['host'] = 'localhost'
default[tcb]['database']['user_name'] = nil

default[tcb]['database']['set_root_pw'] = true
default[tcb]['database']['root_pw']['vault_data_bag'] = 'passwords'
default[tcb]['database']['root_pw']['vault_bag_item'] = nil
default[tcb]['database']['root_pw']['vault_item_key'] = 'db_root'

default[tcb]['database']['user_pw']['vault_data_bag'] = 'passwords'
default[tcb]['database']['user_pw']['vault_bag_item'] = nil
default[tcb]['database']['user_pw']['vault_item_key'] = 'db_user'

default[tcb]['database']['configure_backup'] = true
default[tcb]['database']['backup']['directory'] = nil
default[tcb]['database']['backup']['weekday'] = '0'
default[tcb]['database']['backup']['day'] = '*'
default[tcb]['database']['backup']['hour'] = '4'

default[tcb]['database']['backup']['copy_to_s3'] = false
default[tcb]['database']['backup']['delete_local_copy'] = false
default[tcb]['database']['backup']['s3_path'] = nil
