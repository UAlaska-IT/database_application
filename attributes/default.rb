# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_firewall'] = true

default[tcb]['configure_backup'] = true

default[tcb]['mariadb_version'] = '10.4'

default[tcb]['postgresql_version'] = '12'
