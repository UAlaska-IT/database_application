# frozen_string_literal: true

tcb = 'database_application'

host = node[tcb]['host']
user = node[tcb]['user_name']
pass = vault_secret_hash(node[tcb]['user_pw'])
database = node['database_application']['database']['db_name']

code = ''
if node[tcb]['configure_mariadb'] && File.exist?(compress_path(latest_path('mariadb')))
  code += extract_command('mariadb')
  code += "\nmysql -u #{user} -p'#{pass}' #{database} < #{latest_path('mariadb')}"
  code += extract_delete_command('mariadb')
end

if node[tcb]['configure_postgresql'] && File.exist?(compress_path(latest_path('postgresql')))
  code += extract_command('postgresql')
  code += "\nPGPASSWORD='#{pass}' psql -h #{host} -U #{user} #{database} < #{latest_path('postgresql')}"
  code += extract_delete_command('postgresql')
end

bash 'Restore Database' do
  code code
  cwd default_backup_directory
end
