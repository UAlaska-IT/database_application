# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['configure_firewall'] = true

default[tcb]['configure_backup'] = true
