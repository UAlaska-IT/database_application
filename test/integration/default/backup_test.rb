# frozen_string_literal: true

require_relative '../helpers'

# node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

backup_dir = '/var/backups/codeigniter'

describe file backup_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode '750' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

cron_file = '/etc/cron.d/database_backup'

describe file cron_file do
  it { should exist }
  it { should be_file }
  it { should be_mode '600' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
  its(:content) { should match('-h localhost') }
  its(:content) { should match('-u bud') }
  its(:content) { should match('-p \'PasswordIsASecurePassword\'') }
  its(:content) { should match('not_used') }
  its(:content) { should_not match('aws') }
end
