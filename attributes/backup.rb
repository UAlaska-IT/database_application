# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['backup']['directory'] = '/var/opt/database_application/backups'
default[tcb]['backup']['weekday'] = '0'
default[tcb]['backup']['day'] = '*'
default[tcb]['backup']['hour'] = '6'

default[tcb]['backup']['copy_to_s3'] = false
default[tcb]['backup']['delete_local_copy'] = false
default[tcb]['backup']['s3_path'] = nil
