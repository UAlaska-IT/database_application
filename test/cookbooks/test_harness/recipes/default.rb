# frozen_string_literal: true

bash 'Poison Hosts' do
  code 'echo 127.0.0.1 db.example.com >> /etc/hosts'
end

include_recipe 'database_application::server'

include_recipe 'database_application::client'

bash 'Run Backups' do
  code '/var/chef/database_application_backup.sh'
end
