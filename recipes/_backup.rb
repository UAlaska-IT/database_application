# frozen_string_literal: true

tcb = 'database_application'

directory default_backup_directory do
  owner 'root'
  group 'root'
  mode '750'
end

host = node[tcb]['database']['host']
user = node[tcb]['database']['user_name']
pass = vault_secret_hash(node[tcb]['database']['user_pw'])
database = node['database_application']['database']['db_name']
time_stamp = Time.now.strftime('%Y-%m-%d')

code = ''
if node[tcb]['database']['configure_mariadb']
  time_path = time_path('mariadb', time_stamp)
  code += "\nmysqldump -h #{host} -u #{user} -p'#{pass}' #{database} -c > #{time_path}"
  code += backup_command('mariadb', time_stamp)
end

if node[tcb]['database']['configure_postgresql']
  time_path = time_path('postgresql', time_stamp)
  code += "\nPGPASSWORD='#{pass}' pg_dump -h #{host} -U #{user} #{database} > #{time_path}"
  code += backup_command('postgresql', time_stamp)
end

cron_d 'database_backup' do
  command code
  shell '/bin/bash'
  weekday node[tcb]['database']['backup']['weekday']
  day node[tcb]['database']['backup']['day']
  hour node[tcb]['database']['backup']['hour']
end
