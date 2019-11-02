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
      dir = node[TCB]['backup']['directory']
      return dir if dir

      return File.join('/var/backups', node[TCB]['base_name'])
    end

    def time_file(db_type, db_name, time_stamp)
      return "backup_#{db_type}_#{db_name}_#{time_stamp}.sql"
    end

    def latest_file(db_type, db_name)
      return "backup_#{db_type}_#{db_name}_latest.sql"
    end

    def compress_file(file_name)
      return "#{file_name}.z7"
    end

    def time_path(db_type, db_name, time_stamp)
      return "'#{File.join(default_backup_directory, time_file(db_type, db_name, time_stamp))}'"
    end

    def latest_path(db_type, db_name)
      return "'#{File.join(default_backup_directory, latest_file(db_type, db_name))}'"
    end

    def compress_path(file_name)
      return "'#{File.join(default_backup_directory, compress_file(file_name))}'"
    end

    def connection_info(db_hash)
      host = node[TCB]['host']
      db_name = db_hash['db_name']
      return host, db_name
    end

    def user_credentials(db_hash)
      username = db_hash['user_names'].first
      password = user_password(username)
      return username, password
    end

    def dump_command(db_type, db_hash, time_stamp)
      is_maria = db_type == 'mariadb'
      host, db_name = connection_info(db_hash)
      username, password = user_credentials(db_hash)
      time_path = time_path(db_type, db_name, time_stamp)
      return "\nmysqldump -h #{host} -u #{username} -p'#{password}' #{db_name} -c > #{time_path}" if is_maria

      return "\nPGPASSWORD='#{password}' pg_dump -h #{host} -U #{username} #{db_name} > #{time_path}"
    end

    def compress_command(db_type, db_name, time_stamp)
      time_file = time_file(db_type, db_name, time_stamp)
      return "\np7z a #{compress_path(time_file)} #{time_path(db_type, db_name, time_stamp)}"
    end

    def copy_command(db_type, db_name, time_stamp)
      return "\ncp #{time_path(db_type, db_name, time_stamp)} #{latest_path(db_type, db_name)}"
    end

    def s3_path(file)
      s3 = "s3://#{node[TCB]['backup']['s3_path']}"
      s3 += '/' unless s3.match?(%r{/$})
      s3 += file
      return s3
    end

    def s3_copy_command(db_type, db_name, time_stamp)
      code = <<~CODE
        \n# Copy both files to S3
        aws s3 cp #{time_path(db_type, db_name, time_stamp)} #{s3_path(time_file(db_type, db_name, time_stamp))}
        aws s3 cp #{latest_path(db_type, db_name)} #{s3_path(latest_file(db_type, db_name))}
      CODE
      return code
    end

    def backup_command(db_type, db_hash, time_stamp)
      db_name = db_hash['db_name']
      code = ''
      code += dump_command(db_type, db_hash, time_stamp)
      code += compress_command(db_type, db_name, time_stamp)
      code += copy_command(db_type, db_name, time_stamp)
      code += s3_copy_command(db_type, db_name, time_stamp) if node[TCB]['backup']['copy_to_s3']
      return code
    end

    def bash_out(command)
      stdout, stderr, status = Open3.capture3(command)
      raise "Error: #{stderr}" unless stderr.empty?

      raise "Status: #{status}" if status != 0

      return stdout
    end

    def bash_log_out(command)
      stdout = bash_out(command)
      Chef::Log.info("\n#{stdout}\n\n")
    end

    def fetch_archive_from_s3(db_type, db_hash)
      db_name = db_hash['db_name']
      command = "aws s3 cp #{s3_path(latest_file(db_type, db_name))} #{latest_path(db_type, db_name)}"
      bash_log_out(command)
    end

    def extract_restore_sql(db_type, db_name)
      compress_path = compress_path(latest_file(db_type, db_name))
      command = "\n7z e #{compress_path}"
      bash_log_out(command)
    end

    def run_restore_sql(db_type, db_hash)
      host, db_name = connection_info(db_hash)
      username, password = user_credentials(db_hash)
      latest_path = latest_path(db_type, db_name)
      command =
        if db_type == 'mariadb'
          "\nmysql -u #{username} -p'#{password}' #{db_name} < #{latest_path}"
        else
          "\nPGPASSWORD='#{password}' psql -h #{host} -U #{username} #{db_name} < #{latest_path}"
        end
      bash_log_out(command)
    end

    def delete_restore_sql(db_type, db_name)
      latest_path = latest_path(db_type, db_name)
      command = "\nrm #{latest_path}"
      bash_log_out(command)
    end

    def do_restore_database(db_type, db_hash)
      db_name = db_hash['db_name']
      extract_restore_sql(db_type, db_name)
      run_restore_sql(db_type, db_hash)
      delete_restore_sql(db_type, db_name)
    end

    def restore_database(db_type, db_hash)
      db_name = db_hash['db_name']
      unless File.exist?(compress_path(latest_path(db_type, db_name)))
        if node[TCB]['backup']['copy_to_s3']
          fetch_archive_from_s3(db_type, db_hash)
        else
          Chef::Log.fatal("\nArchive for database #{db_name} not found\n\n")
        end
      end
      do_restore_database(db_type, db_hash)
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
