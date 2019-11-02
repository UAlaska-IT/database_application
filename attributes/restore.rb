# frozen_string_literal: true

tcb = 'database_application'

default[tcb]['restore']['database']['mariadb'] = nil
default[tcb]['restore']['database']['postgresql'] = nil
