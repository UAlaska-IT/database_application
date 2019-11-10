# frozen_string_literal: true

def installed_command(node)
  return 'apt list --installed' if node['platform_family'] == 'debian'

  return 'yum list installed'
end

# rubocop:disable Metrics/MethodLength
def users_hash
  return {
    'bud' => {
      'password' => 'PasswordIsASecurePassword',
      'additional_hosts' => [
        'db.example.com',
      ],
    },
    'sri' => {
      'password' => '12345678IsASecurePassword',
    },
  }
end

def mariadb_dbs
  return [
    {
      'db_name' => 'secret_db',
      'user_names' => [
        'sri',
        'bud',
      ],
    },
    {
      'db_name' => 'small_db',
      'user_names' => [
        'sri',
      ],
    },
  ]
end

def postgresql_dbs
  return [
    {
      'db_name' => 'public_db',
      'user_names' => [
        'bud',
      ],
    },
    {
      'db_name' => 'large_db',
      'user_names' => [
        'bud',
        'sri',
      ],
    },
  ]
end

# rubocop:enable Metrics/MethodLength

def append_additional_hosts(user, hosts)
  user_hash = users_hash[user]
  return unless user_hash.key?('additional_hosts')

  user_hash['additional_hosts'].each do |host|
    hosts.append(host)
  end
end

def hosts_for_user(user)
  hosts = [
    'localhost',
    '127.0.0.1',
  ]
  append_additional_hosts(user, hosts)
  return hosts
end
