# frozen_string_literal: true

bash 'Public Hostname' do
  code 'hostnamectl set-hostname `curl -s http://169.254.169.254/latest/meta-data/public-hostname`'
end

bash 'Poison Hosts' do
  code 'echo 127.0.0.1 db.example.com >> /etc/hosts'
end

include_recipe 'database_application::server'

include_recipe 'database_application::client'

bash 'Run Backups' do
  code '/var/chef/database_application_backup.sh'
end
