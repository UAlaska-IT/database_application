# frozen_string_literal: true

name 'database_application'
maintainer 'OIT Systems Engineering'
maintainer_email 'ua-oit-se@alaska.edu'
license 'MIT'
description 'Configures possibly multiple databases for both MariaDB and PostgreSQL'

git_url = 'https://github.com/UAlaska-IT/database_application'
source_url git_url
issues_url "#{git_url}/issues"

version '0.1.0'

supports 'ubuntu', '>= 18.0'
supports 'centos', '>= 7.0'

chef_version '>= 14.0'

depends 'checksum_file'
depends 'chef_run_recorder'
depends 'chef-vault'
depends 'firewall'
depends 'idempotence_file'
depends 'mariadb'
depends 'postgresql'
depends 'yum-epel'
