# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

describe bash('yum repolist') do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match 'epel/x86_64' }
  before do
    skip if node['platform_family'] == 'debian'
  end
end

ver_dir = '/var/chef/idempotence'

describe file(File.join(ver_dir, 'database_application_mariadb_version')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match '10.4' }
end

describe file(File.join(ver_dir, 'database_application_postgresql_version')) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match '12' }
end

describe package 'p7zip-full' do
  it { should be_installed } if node['platform_family'] == 'debian'
end

describe package 'p7zip' do
  it { should be_installed } unless node['platform_family'] == 'debian'
end

describe package 'python3' do
  it { should be_installed }
end

describe package 'python3-pip' do
  it { should be_installed }
end

describe bash('pip3 list') do
  its(:exit_status) { should eq 0 }
  # its(:stderr) { should eq '' }
  its(:stdout) { should match 'awscli' }
end
