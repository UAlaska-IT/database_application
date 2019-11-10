# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

# Installs

describe bash installed_command(node) do
  its(:exit_status) { should eq 0 }
  # its(:stderr) { should eq '' }
  its(:stdout) { should match(/mariadb-server-10/) }
  its(:stdout) { should match(/postgresql-12/) }
  before do
    skip unless node['platform_family'] == 'debian'
  end
end

describe bash installed_command(node) do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/MariaDB-server/) }
  its(:stdout) { should match(/@mariadb10\.4/) }
  its(:stdout) { should match(/postgresql12-server/) }
  before do
    skip if node['platform_family'] == 'debian'
  end
end

describe bash 'mysql --version' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/10\.4/) }
end

describe bash 'psql --version' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/12\.0/) }
end

describe service 'mariadb' do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

postgre_service =
  if node['platform_family'] == 'debian'
    'postgresql'
  else
    'postgresql-12'
  end

describe service postgre_service do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end
