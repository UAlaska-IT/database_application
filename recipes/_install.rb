# frozen_string_literal: true

# Compensate for the king-of-snowflakes distro
include_recipe 'yum-epel::default'

is_debian = platform_family?('debian')

package 'p7zip-full' if is_debian
package 'p7zip' unless is_debian
