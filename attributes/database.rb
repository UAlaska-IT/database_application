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

default[tcb]['configure_backup'] = true
default[tcb]['backup']['directory'] = nil
default[tcb]['backup']['weekday'] = '0'
default[tcb]['backup']['day'] = '*'
default[tcb]['backup']['hour'] = '4'

default[tcb]['backup']['copy_to_s3'] = false
default[tcb]['backup']['delete_local_copy'] = false
default[tcb]['backup']['s3_path'] = nil
