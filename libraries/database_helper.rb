# frozen_string_literal: true

module DatabaseApplication
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'database_application'

    def configure_firewall?
      return node[TCB]['configure_firewall']
    end

    def mariadb_server?
      return node[TCB]['database']['mariadb'].any?
    end

    def postgresql_server?
      return node[TCB]['database']['postgresql'].any?
    end

    def default_host_list(db_type)
      return node[TCB]['database']['mariadb_hosts'] if db_type == 'mariadb'

      return node[TCB]['database']['postgresql_addresses']
    end

    def default_hosts(db_type)
      hosts = {}
      default_host_list(db_type).each do |host|
        hosts[host] = nil
      end
      return hosts
    end

    def hosts_for_user(db_type, user_hash)
      hosts = default_hosts(db_type)
      if user_hash.key?('additional_hosts')
        user_hash['additional_hosts'].each do |host|
          hosts[host] = nil
        end
      end
      return hosts.keys
    end

    def postgresql_data_directory
      return "/etc/postgresql/#{node[TCB]['postgresql_version']}/main" if platform_family?('debian')

      return "/var/lib/pgsql/#{node[TCB]['postgresql_version']}/data"
    end

    def path_to_postgresql_hba_conf
      return File.join(postgresql_data_directory, 'pg_hba.conf')
    end

    def zip_command
      return '7z' if platform_family?('debian')

      return '7za'
    end

    def database_backup_directory
      return node[TCB]['backup']['directory']
    end

    def backup_file(db_type, db_name)
      return "backup_#{db_type}_#{db_name}.sql"
    end

    def time_file(db_type, db_name)
      return "backup_#{db_type}_#{db_name}_${TIMESTAMP}.sql.7z"
    end

    def latest_file(db_type, db_name)
      return "backup_#{db_type}_#{db_name}_latest.sql.7z"
    end

    def backup_path(db_type, db_name)
      return "'#{File.join(database_backup_directory, backup_file(db_type, db_name))}'"
    end

    def time_path(db_type, db_name)
      return "\"#{File.join(database_backup_directory, time_file(db_type, db_name))}\""
    end

    def latest_path(db_type, db_name)
      return "'#{File.join(database_backup_directory, latest_file(db_type, db_name))}'"
    end

    def local_connection_info(db_hash)
      return 'localhost', db_hash['db_name']
    end

    def user_credentials(db_hash)
      username = db_hash['user_names'].first
      password = user_password(username)
      return username, password
    end

    def dump_command(db_type, db_hash)
      maria = db_type == 'mariadb'
      host, db_name = local_connection_info(db_hash)
      username, password = user_credentials(db_hash)
      backup_path = backup_path(db_type, db_name)
      code = "\n# Dump the database"
      code += "\nmysqldump -h #{host} -u #{username} -p'#{password}' #{db_name} -c > #{backup_path}" if maria
      code += "\nPGPASSWORD='#{password}' pg_dump -h #{host} -U #{username} #{db_name} > #{backup_path}" unless maria
      return code
    end

    def compress_command(db_type, db_name)
      code = <<~CODE
        \n\n# Create time stamp and make timed copy
        export TIMESTAMP=`date "+%Y_%m_%d_%H"`
        #{zip_command} a #{time_path(db_type, db_name)} #{backup_path(db_type, db_name)}
        rm #{backup_path(db_type, db_name)}
      CODE
      return code
    end

    def permissions_command(db_type, db_name)
      code = <<~CODE
        \n# Give reasonable permissions (the directory is already protected, so little worry of race conditions)
        chmod 640 #{backup_path(db_type, db_name)}
        chmod 640 #{time_path(db_type, db_name)}
      CODE
      return code
    end

    def copy_command(db_type, db_name)
      code = <<~CODE
        \n# Copy new file as latest
        cp #{time_path(db_type, db_name)} #{latest_path(db_type, db_name)}

      CODE
      return code
    end

    def s3_path(file)
      s3 = "s3://#{node[TCB]['backup']['s3_path']}"
      s3 += '/' unless s3.match?(%r{/$})
      s3 += file
      return "\"#{s3}\""
    end

    def s3_copy_command(db_type, db_name)
      code = <<~CODE
        \n# Copy both files to S3
        aws s3 cp #{time_path(db_type, db_name)} #{s3_path(time_file(db_type, db_name))}
        aws s3 cp #{latest_path(db_type, db_name)} #{s3_path(latest_file(db_type, db_name))}

      CODE
      return code
    end

    def backup_command(db_type, db_hash)
      db_name = db_hash['db_name']
      code = dump_command(db_type, db_hash)
      code += compress_command(db_type, db_name)
      code += permissions_command(db_type, db_name)
      code += copy_command(db_type, db_name)
      code += s3_copy_command(db_type, db_name) if node[TCB]['backup']['copy_to_s3']
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
      Chef::Log.info("\n\n#{stdout}\n")
    end

    def fetch_archive_from_s3(db_type, db_hash)
      db_name = db_hash['db_name']
      command = "aws s3 cp #{s3_path(latest_file(db_type, db_name))} #{latest_path(db_type, db_name)}"
      bash_log_out(command)
    end

    def extract_restore_sql(db_type, db_name)
      latest_path = latest_path(db_type, db_name)
      command = "\n#{zip_command} e #{latest_path}"
      bash_log_out(command)
    end

    def run_restore_sql(db_type, db_hash)
      host, db_name = local_connection_info(db_hash)
      username, password = user_credentials(db_hash)
      backup_path = backup_path(db_type, db_name)
      command =
        if db_type == 'mariadb'
          "\nmysql -u #{username} -p'#{password}' #{db_name} < #{backup_path}"
        else
          "\nPGPASSWORD='#{password}' psql -h #{host} -U #{username} #{db_name} < #{backup_path}"
        end
      bash_log_out(command)
    end

    def delete_restore_sql(db_type, db_name)
      backup_path = backup_path(db_type, db_name)
      command = "\nrm #{backup_path}"
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
      unless File.exist?(latest_path(db_type, db_name))
        if node[TCB]['backup']['copy_to_s3']
          fetch_archive_from_s3(db_type, db_hash)
        else
          Chef::Log.fatal("\n\nArchive for database #{db_name} not found\n")
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
      return user_hash['vault_item_key'] if user_hash.key?('vault_item_key')

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
