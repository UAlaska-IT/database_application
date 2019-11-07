# frozen_string_literal: true

tcb = 'database_application'

id_tag = 'Pre-Install Update'

apt_update id_tag do
  action :update
  not_if { idempotence_file?(id_tag) }
end

idempotence_file id_tag

# Compensate for the king-of-snowflakes distro
include_recipe 'yum-epel::default'

mariadb_file = '/var/chef/idempotence/database_application_mariadb_version'

file 'mariadb_file' do
  path mariadb_file
  content node[tcb]['mariadb_version']
end

postgresql_file = '/var/chef/idempotence/database_application_postgresql_version'

file 'postgresql_file' do
  path postgresql_file
  content node[tcb]['postgresql_version']
end

[
  'mariadb-client',
  'mariadb-server',
].each do |package|
  package package do
    action :nothing
    subscribes :remove, 'file[mariadb_file]', :immediate
  end
end

[
  'postgresql',
  'postgresql-client',
  'postgresql-devel',
  'postgresql-libs',
  'postgresql-server',
  'postgresql-upgrade',
].each do |package|
  package package do
    action :nothing
    subscribes :remove, 'file[postgresql_file]', :immediate
  end
end

is_debian = platform_family?('debian')

package 'p7zip-full' if is_debian
package 'p7zip' unless is_debian

package 'python3' do
  only_if { node[tcb]['configure_backup'] }
end

package 'python3-pip' do
  only_if { node[tcb]['configure_backup'] }
end

bash 'Install AWS CLI' do
  code 'pip3 install awscli'
  not_if 'pip3 list | grep awscli'
  only_if { node[tcb]['configure_backup'] }
end
