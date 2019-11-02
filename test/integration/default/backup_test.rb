# frozen_string_literal: true

require_relative '../helpers'

# node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

backup_dir = '/var/backups/test_db'

describe file backup_dir do
  it { should exist }
  it { should be_directory }
  it { should be_mode '750' }
  it { should be_owned_by 'root' }
  it { should be_grouped_into 'root' }
end

backup_script = '/var/chef/database_application_backup.sh'

describe file backup_script do
  it { should exist }
  it { should be_file }
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

time_stamp = Time.now.strftime('%Y_%m_%d_%H_%M')

{
  mariadb: [
    'secret_db',
    'small_db',
  ],
  postgresql: [
    'public_db',
    'large_db',
  ],
}.each do |db_type, db_names|
  db_names.each do |db_name|
    db_tag = "#{db_type}_#{db_name}"
    time_file = File.join(backup_dir, "backup_#{db_tag}_#{time_stamp}.sql.7z")
    latest_file = File.join(backup_dir, "backup_#{db_tag}_latest.sql.7z")

    describe file backup_script do
      its(:content) { should match("#{db_name} -c > '#{backup_dir}/backup_#{db_tag}.sql") }
      its(:content) { should match("7z a '#{backup_dir}/backup_#{db_tag}_${TIMESTAMP}.sql.7z' '#{backup_dir}/backup_#{db_tag}.sql'") }
      its(:content) { should match("chmod 640 '#{backup_dir}/backup_#{db_tag}.sql'") }
      its(:content) { should match("chmod 640 '#{backup_dir}/backup_#{db_tag}_${TIMESTAMP}.sql.7z'") }
      its(:content) { should match("cp '#{backup_dir}/backup_#{db_tag}_${TIMESTAMP}.sql.7z' '/var/backups/test_db/backup_#{db_tag}_latest.sql.7z'") }
    end

    describe file time_file do
      it { should exist }
      it { should be_file }
      it { should be_mode '640' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe file latest_file do
      it { should exist }
      it { should be_file }
      it { should be_mode '640' }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end
  end
end
