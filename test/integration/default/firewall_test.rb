# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

firewall_conf = if node['platform_family'] == 'debian'
                  '/etc/default/ufw-chef.rules'
                else
                  '/etc/sysconfig/firewalld-chef.rules'
                end

describe file(firewall_conf) do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o644 }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

describe file(firewall_conf) do
  its(:content) { should match 'ufw allow in proto tcp to any port 3306 from any' }
  its(:content) { should match 'ufw allow in proto tcp to any port 5432 from any' }
  before do
    skip unless node['platform_family'] == 'debian'
  end
end

describe file(firewall_conf) do
  its(:content) { should match '--dports 3306' }
  its(:content) { should match '--dports 5432' }
  before do
    skip if node['platform_family'] == 'debian'
  end
end

describe port(3306) do
  it { should be_listening }
  its('processes') { should eq ['mysqld'] }
  its('protocols') { should eq ['tcp'] }
end

postgre_service =
  if node['platform_family'] == 'debian'
    'postgres'
  else
    'postmaster'
  end

postgre_protocols =
  if node['platform_family'] == 'debian'
    ['tcp']
  else
    ['tcp', 'tcp6']
  end

describe port(5432) do
  it { should be_listening }
  its('processes') { should eq [postgre_service] }
  its('protocols') { should eq postgre_protocols }
end
