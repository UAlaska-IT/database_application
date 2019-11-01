# frozen_string_literal: true

include_recipe 'firewall::default'

firewall_rule 'Allow MariaDB' do
  port 3306
  protocol :tcp
  position 1
  command :allow
  only_if { mariadb_server? }
end

firewall_rule 'Allow PostreSQL' do
  port 5432
  protocol :tcp
  position 1
  command :allow
  only_if { postgresql_server? }
end
