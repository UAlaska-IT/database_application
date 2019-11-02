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
