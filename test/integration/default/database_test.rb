# frozen_string_literal: true

require_relative '../helpers'

node = json('/opt/chef/run_record/last_chef_run_node.json')['automatic']

# Database

describe bash 'mysql -e "show databases;"' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/secret_db/) }
  its(:stdout) { should match(/small_db/) }
end

describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/public_db/) }
  its(:stdout) { should match(/large_db/) }
end

# User

describe bash 'mysql -e "select concat(User,\'@\',Host) from mysql.user;"' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/bud@localhost/) }
  its(:stdout) { should match(/bud@127\.0\.0\.1/) }
  its(:stdout) { should match(/bud@db\.example\.com/) }
  its(:stdout) { should match(/sri@localhost/) }
  its(:stdout) { should match(/sri@127\.0\.0\.1/) }
end

# PostgreSQL user test is implicit in login method
users_hash.each do |user, user_hash|
  hosts_for_user(user).each do |host|
    describe bash "PGPASSWORD=#{user_hash['password']} psql -U #{user} -h #{host} -l" do
      its(:exit_status) { should eq 0 }
      its(:stderr) { should eq '' }
    end
  end
end

# Access

describe bash 'mysql -e "show grants for bud@localhost;"' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/GRANT ALL PRIVILEGES ON `secret_db`/) }
end

describe bash 'mysql -e "show grants for sri@localhost;"' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/GRANT ALL PRIVILEGES ON `secret_db`/) }
  its(:stdout) { should match(/GRANT ALL PRIVILEGES ON `small_db`/) }
end

psql_command = '-c "CREATE TABLE IF NOT EXISTS test_table (i integer);"'

postgresql_dbs.each do |db_hash|
  db_hash['user_names'].each do |user|
    user_hash = users_hash[user]
    pass = user_hash['password']
    hosts_for_user(user).each do |host|
      describe bash "PGPASSWORD=#{pass} psql -U #{user} -h #{host} -d #{db_hash['db_name']} #{psql_command}" do
        its(:exit_status) { should eq 0 }
        # its(:stderr) { should eq '' }
        its(:stdout) { should match(/CREATE TABLE/) }
      end
    end
  end
end

pg_hba_dir =
  if node['platform_family'] == 'debian'
    '/etc/postgresql/12/main'
  else
    '/var/lib/pgsql/12/data'
  end
pg_hba = File.join(pg_hba_dir, 'pg_hba.conf')

describe file pg_hba do
  it { should exist }
  it { should be_file }
  it { should be_mode 0o600 }
  it { should be_owned_by 'postgres' }
  it { should be_grouped_into 'postgres' }
  its(:content) { should match(/local\s+all\s+postgres\s+peer/) }
  its(:content) { should match(/local\s+all\s+all\s+md5/) }
  its(:content) { should match(%r{host\s+all\s+all\s+127\.0\.0\.1/32\s+md5}) }
  its(:content) { should match(%r{host\s+all\s+all\s+::1/128\s+md5}) }

  its(:content) { should match(/host\s+public_db\s+bud\s+localhost\s*md5/) }
  its(:content) { should match(%r{host\s+public_db\s+bud\s+127\.0\.0\.1/32\s+md5}) }
  its(:content) { should match(/host\s+public_db\s+bud\s+db\.example\.com\s*md5/) }

  its(:content) { should match(/host\s+large_db\s+bud\s+localhost\s*md5/) }
  its(:content) { should match(%r{host\s+large_db\s+bud\s+127\.0\.0\.1/32\s+md5}) }
  its(:content) { should match(/host\s+large_db\s+bud\s+db\.example\.com\s*md5/) }

  its(:content) { should match(/host\s+large_db\s+sri\s+localhost\s*md5/) }
  its(:content) { should match(%r{host\s+large_db\s+sri\s+127\.0\.0\.1/32\s+md5}) }
end
