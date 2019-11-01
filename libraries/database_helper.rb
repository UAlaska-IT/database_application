# frozen_string_literal: true

module DatabaseApplication
  # This module implements shared utility code for consistency with dependent cookbooks
  module Helper
    TCB = 'database_application'

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
