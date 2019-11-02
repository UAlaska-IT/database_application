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
