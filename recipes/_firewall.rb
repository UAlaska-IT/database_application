# frozen_string_literal: true

include_recipe 'firewall::default'

firewall_rule 'Allow MariaDB' do
  port 3306
  protocol :tcp
  position 1
  command :allow
end

firewall_rule 'Allow PostreSQL' do
  port 5432
  protocol :tcp
  position 1
  command :allow
end
