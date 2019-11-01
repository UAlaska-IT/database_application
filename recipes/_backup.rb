# frozen_string_literal: true

tcb = 'database_application'

directory default_backup_directory do
  owner 'root'
  group 'root'
  mode '750'
end

host = node[tcb]['host']
user = node[tcb]['user_name']
pass = vault_secret_hash(node[tcb]['user_pw'])
database = node['database_application']['database']['db_name']
time_stamp = Time.now.strftime('%Y-%m-%d')

code = ''
if node[tcb]['configure_mariadb']
  time_path = time_path('mariadb', time_stamp)
  code += "\nmysqldump -h #{host} -u #{user} -p'#{pass}' #{database} -c > #{time_path}"
  code += backup_command('mariadb', time_stamp)
end

if node[tcb]['configure_postgresql']
  time_path = time_path('postgresql', time_stamp)
  code += "\nPGPASSWORD='#{pass}' pg_dump -h #{host} -U #{user} #{database} > #{time_path}"
  code += backup_command('postgresql', time_stamp)
end

cron_d 'database_backup' do
  command code
  shell '/bin/bash'
  weekday node[tcb]['backup']['weekday']
  day node[tcb]['backup']['day']
  hour node[tcb]['backup']['hour']
end
