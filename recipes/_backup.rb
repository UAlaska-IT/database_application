# frozen_string_literal: true

tcb = 'database_application'

directory default_backup_directory do
  owner 'root'
  group 'root'
  mode '750'
end

time_stamp = Time.now.strftime('%Y-%m-%d')
code = ''

node[tcb]['database']['mariadb'].each do |db_hash|
  code += backup_command('mariadb', db_hash, time_stamp)
end

node[tcb]['database']['postgresql'].each do |db_hash|
  code += backup_command('postgresql', db_hash, time_stamp)
end

backup_script = '/var/chef/database_application_backup.sh'

file backup_script do
  content code
  owner 'root'
  group 'root'
  mode '750'
end

cron_d 'database_backup' do
  command backup_script
  shell '/bin/bash'
  weekday node[tcb]['backup']['weekday']
  day node[tcb]['backup']['day']
  hour node[tcb]['backup']['hour']
end
