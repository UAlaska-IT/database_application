# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['restore']['mariadb']['databases'] = nil
default[tcb]['restore']['postgresql']['databases'] = nil
