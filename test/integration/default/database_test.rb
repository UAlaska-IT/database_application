# frozen_string_literal: true

require_relative '../helpers'

# Database

describe bash 'mysql -e \'show databases;\'' do
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

describe bash 'mysql -e \'select User from mysql.user;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  its(:stdout) { should match(/bud/) }
  its(:stdout) { should match(/sri/) }
end

# PostgreSQL user test is implicit in login method

# Access

describe bash 'mysql -e \'show grants for bud@localhost;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  # TODO: A test for table privilege
  its(:stdout) { should match(/GRANT ALL PRIVILEGES/) }
end

describe bash 'mysql -e \'show grants for sri@localhost;\'' do
  its(:exit_status) { should eq 0 }
  its(:stderr) { should eq '' }
  # TODO: A test for table privilege
  its(:stdout) { should match(/GRANT ALL PRIVILEGES/) }
  its(:stdout) { should match(/GRANT ALL PRIVILEGES/) }
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
