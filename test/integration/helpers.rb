# frozen_string_literal: true

def installed_command(node)
  return 'apt list --installed' if node['platform_family'] == 'debian'

  return 'yum list installed'
end
