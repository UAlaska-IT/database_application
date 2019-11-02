# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

# Installs

describe bash installed_command(node) do
  its(:exit_status) { should eq 0 }
  # its(:stderr) { should eq '' }
  its(:stdout) { should match(/mariadb-client-10/) }
  its(:stdout) { should match(/postgresql-client-9/) }
end
