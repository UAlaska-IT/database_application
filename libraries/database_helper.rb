# frozen_string_literal: true

module DatabaseApplication
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'database_application'

    def local_database?
      return node[TCB]['host'] == 'localhost'
    end

    def configure_firewall?
      return node[TCB]['configure_firewall'] && !local_database?
    end

    def mariadb_server?
      return node[TCB]['database']['mariadb'].any?
    end

    def postgresql_server?
      return node[TCB]['database']['postgresql'].any?
    end

    def default_backup_directory
      dir = node[tcb]['backup']['directory']
      return dir if dir

      return File.join('/var/backups', node[TCB]['base_name'])
    end

    def time_file(db_type, time_stamp)
      return "backup_#{db_type}_#{time_stamp}.sql"
    end

    def latest_file(db_type)
      return "backup_#{db_type}_latest.sql"
    end

    def compress_file(file_name)
      return "#{file_name}.z7"
    end

    def time_path(db_type, time_stamp)
      return "'#{File.join(default_backup_directory, time_file(db_type, time_stamp))}'"
    end

    def latest_path(db_type)
      return "'#{File.join(default_backup_directory, latest_file(db_type))}'"
    end

    def compress_path(file_name)
      return "'#{File.join(default_backup_directory, compress_file(file_name))}'"
    end

    def compress_command(db_type, time_stamp)
      time_file = time_file(db_type, time_stamp)
      return "\np7z a #{compress_path(time_file)} #{time_path(db_type, time_stamp)}"
    end

    def copy_command(db_type, time_stamp)
      return "\ncp #{time_path(db_type, time_stamp)} #{latest_path(db_type)}"
    end

    def s3_path(file)
      s3 = "s3://#{node[tcb]['backup']['s3_path']}"
      s3 += '/' unless s3.match?(%r{/$})
      s3 += file
      return s3
    end

    def s3_copy_command(db_type, time_stamp)
      code = <<~CODE
        \n# Copy both files to S3
        aws s3 cp #{time_path(db_type, time_stamp)} #{s3_path(time_file(db_type, time_stamp))}
        aws s3 cp #{latest_path(db_type)} #{s3_path(latest_file(db_type))}
      CODE
      return code
    end

    def backup_command(db_type, time_stamp)
      code = ''
      code += compress_command(db_type, time_stamp)
      code += copy_command(db_type, time_stamp)
      code += s3_copy_command(db_type, time_stamp) if node[tcb]['backup']['copy_to_s3']
      return code
    end

    def extract_command(db_type)
      compress_path = compress_path(latest_file(db_type))
      return "\n7z e #{compress_path}"
    end

    def extract_delete_command(db_type)
      latest_path = latest_path(db_type)
      return "\nrm #{latest_path}"
    end

    def set_root_password?
      return node[TCB]['database']['users'].key?('root')
    end

    def user_password_default(user_hash, key)
      return user_hash[key] if user_hash.key?(key)

      return node[TCB]['database']['user_pw'][key]
    end

    def user_password_key(user_name, user_hash)
      return user_hash['vault_bag_item'] if user_hash.key?('vault_bag_item')

      return user_name
    end

    def user_password(user_name)
      user_hash = node[TCB]['database']['users'][user_name]
      bag = user_password_default(user_hash, 'vault_data_bag')
      item = user_password_default(user_hash, 'vault_bag_item')
      key = user_password_key(user_name, user_hash)
      return vault_secret(bag, item, key)
    end

    def vault_secret(bag, item, key)
      # Will raise 404 error if not found
      item = chef_vault_item(
        bag,
        item
      )
      raise 'Unable to retrieve vault item' if item.nil?

      secret = item[key]
      raise 'Unable to retrieve item key' if secret.nil?

      return secret
    end

    def vault_secret_hash(object)
      return vault_secret(object['vault_data_bag'], object['vault_bag_item'], object['vault_item_key'])
    end
  end
end

Chef::Provider.include(DatabaseApplication::Helper)
Chef::Recipe.include(DatabaseApplication::Helper)
Chef::Resource.include(DatabaseApplication::Helper)
