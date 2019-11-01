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
      return node[TCB]['mariadb']['databases'].any?
    end

    def postgresql_server?
      return node[TCB]['postgresql']['databases'].any?
    end

    def default_backup_directory
      dir = node[tcb]['backup']['directory']
      return dir if dir

      return File.join('/var/backups', node[TCB]['base_name'])
    end

    def time_file(db_name, time_stamp)
      return "backup_#{db_name}_#{time_stamp}.sql"
    end

    def latest_file(db_name)
      return "backup_#{db_name}_latest.sql"
    end

    def compress_file(file_name)
      return "#{file_name}.z7"
    end

    def time_path(db_name, time_stamp)
      return "'#{File.join(default_backup_directory, time_file(db_name, time_stamp))}'"
    end

    def latest_path(db_name)
      return "'#{File.join(default_backup_directory, latest_file(db_name))}'"
    end

    def compress_path(file_name)
      return "'#{File.join(default_backup_directory, compress_file(file_name))}'"
    end

    def compress_command(db_name, time_stamp)
      time_file = time_file(db_name, time_stamp)
      return "\np7z a #{compress_path(time_file)} #{time_path(db_name, time_stamp)}"
    end

    def copy_command(db_name, time_stamp)
      return "\ncp #{time_path(db_name, time_stamp)} #{latest_path(db_name)}"
    end

    def s3_path(file)
      s3 = "s3://#{node[tcb]['backup']['s3_path']}"
      s3 += '/' unless s3.match?(%r{/$})
      s3 += file
      return s3
    end

    def s3_copy_command(db_name, time_stamp)
      code = <<~CODE
        \n# Copy both files to S3
        aws s3 cp #{time_path(db_name, time_stamp)} #{s3_path(time_file(db_name, time_stamp))}
        aws s3 cp #{latest_path(db_name)} #{s3_path(latest_file(db_name))}
      CODE
      return code
    end

    def backup_command(db_name, time_stamp)
      code = ''
      code += compress_command(db_name, time_stamp)
      code += copy_command(db_name, time_stamp)
      code += s3_copy_command(db_name, time_stamp) if node[tcb]['backup']['copy_to_s3']
      return code
    end

    def extract_command(db_name)
      compress_path = compress_path(latest_file(db_name))
      return "\n7z e #{compress_path}"
    end

    def extract_delete_command(db_name)
      latest_path = latest_path(db_name)
      return "\nrm #{latest_path}"
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
