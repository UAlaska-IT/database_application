# frozen_string_literal: true

bash 'Public Hostname' do
  code 'hostnamectl set-hostname `curl -s http://169.254.169.254/latest/meta-data/public-hostname`'
end

include_recipe 'database_application::server'

include_recipe 'database_application::client'

bash 'Run Backups' do
  code '/var/chef/database_application_backup.sh'
end
