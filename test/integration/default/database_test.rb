# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

installed_command =
  if node['platform_family'] == 'debian'
    'apt list --installed'
  else
    'yum list installed'
  end

# Installs

describe bash installed_command do
  its(:exit_status) { should eq 0 }
  # its(:stderr) { should eq '' }
  # Server
  its(:stdout) { should match(/mariadb-server-10/) }
  its(:stdout) { should match(/postgresql-9/) }
  # Client
  its(:stdout) { should match(/mariadb-client-10/) }
  its(:stdout) { should match(/postgresql-client-9/) }
end

describe service 'mariadb' do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe service 'postgresql' do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

# Database

describe bash 'mysql -e \'show databases;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/not_used/) }
end

describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/not_used/) }
end

# User

describe bash 'mysql -e \'select User from mysql.user;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/bud/) }
end

# PostgreSQL user test is implicit in login method

# Access

describe bash 'mysql -e \'show grants for bud@localhost;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/GRANT ALL PRIVILEGES/) }
end

describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  # TODO: A test for table privilege
  its(:stdout) { should match(/not_used/) }
end
