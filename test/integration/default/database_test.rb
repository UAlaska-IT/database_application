# frozen_string_literal: true

require_relative '../helpers'

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
describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
end
describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h 127.0.0.1 -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
end
describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h db.example.com -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
end
describe bash 'PGPASSWORD=12345678IsASecurePassword psql -U sri -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
end
describe bash 'PGPASSWORD=12345678IsASecurePassword psql -U sri -h 127.0.0.1 -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
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

describe bash 'PGPASSWORD=PasswordIsASecurePassword psql -U bud -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  # TODO: A test for table privilege
  its(:stdout) { should match(/public_db/) }
  its(:stdout) { should match(/large_db/) }
end

describe bash 'PGPASSWORD=12345678IsASecurePassword psql -U sri -h localhost -l' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  # TODO: A test for table privilege
  its(:stdout) { should match(/large_db/) }
end
