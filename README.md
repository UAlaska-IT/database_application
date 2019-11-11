# Database Application Cookbook

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This cookbook configures possibly both MariaDB and PostgreSQL servers and can create multiple databases for each from lists in attributes.
It is intended as a middle ground between managed/enterprise databases and keeping toy databases on-node.

Features:

1. Infrastructure costs for hosting lightly-used databases on compute instances will be small compared to costs for managed databases

    * Less than 1/2 for hosting one database, or if instance size is resource constrained

    * Less than 1/4 for hosting both MariaDB and PostgreSQL, if instance size is not resource constrained

1. Recovery point is within 1 day if remote backups are enabled (configurable)

Limitations:

1. No clustering/replication is done for performance

1. No replication/failover is done for high availability or fault tolerance

1. Labor costs for management of enterprise databases will be high

1. Backup uses brute dumping and transfer of full backups and therefore is unsuitable for large databases

1. Recovery time is unbounded; recovery requires manual intervention to run a recipe

Bottom line, this cookbook provides cheap, backed-up databases for lightly-used applications that require the existence of a database,
but are not sensitive to resources or tuning.
It also supports transient database servers that can be re-created with minimal effort.

The firewall can be configured for remote access, or not for local databases.

Automated dumps can be setup, as well as automated remote backup to AWS S3.
For remote backup to succeed, the node must be configured with an instance profile that provides S3 put privileges for the indicated bucket.

A recovery recipe is included and will recover up to all databases, possibly from S3.
If a local backup exists, it will be used.
For recovery to succeed on a new node that does not have local backups available,
the node must be configured with an instance profile that provides S3 get privileges for the indicated bucket.

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle
* Suse

Platforms validated via Test Kitchen:

* Ubuntu
* Debian
* CentOS
* Suse

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.
It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides no custom resources.

## Recipes

### database_application::server

This recipe configures possibly two database servers and multiple databases.

### database_application::client

This recipe configures possibly two database clients.

### database_application::restore

If a both local databases are configured and backups are configured,
this recipe will restore databases from their latest snapshots.
Otherwise does nothing.

## Attributes

### default

* `node['database_application']['configure_firewall']`.
Defaults to `true`.
If true, firewall ports will be opened for all installed servers.
Please note:

  * This cookbook uses the [firewall cookbook](https://github.com/chef-cookbooks/firewall) to create firewall rules so will conflict with other methods if configured.
  
  * An SSH rule __must__ be created outside of this cookbook or communication will be lost to the node after this cookbook is run. The `firewall::default` rule is used to initialize the firewall, and this recipe respects all attributes of the [firewall cookbook](https://github.com/chef-cookbooks/firewall).
Notably, a world-accessible SSH rule can be created by setting `node['firewall']['allow_ssh']` to `true`.

* `node['database_application']['configure_backup']`.
Defaults to `true`.
If true backups will be created.

Versions to install are specified to the latest when this cookbook was updated.
Other versions will be uninstalled, entailing interruption of service.
Both initialization and upgrade are performed when a new version is installed.
It is advisable to upgrade one release at a time, because the underlying databases do not support arbitrary upgrade steps.

* `node['database_application']['mariadb_version']`.
Defaults to `'10.4'`.
The version of MariaDB to install.

* `node['database_application']['postgresql_version']`.
Defaults to `'12'`.
The version of PostgreSQL to install.

### server

* `node['database_application']['postgresql']['server_locale']`.
Defaults to `'C.UTF-8'`.
The locale for the master database.

Which database servers to install is inferred from database attributes.

### firewall

* `node['database_application']['firewall']['allowed_source']`.
Defaults to `nil`.
If non-nil, will be set as the source for database connections.
For most databases this should be restricted.

### database

Encoding for MariaDB is controlled by two attributes.

* `node['database_application']['mariadb']['db_collation']`.
Defaults to `'utf8_general_ci'`.
This attribute applies to all MariaDB databases that are created.

* `node['database_application']['mariadb']['db_encoding']`.
Defaults to `'utf8'`.
This attribute applies to all MariaDB databases that are created.

Encoding for PostgreSQL databases is controlled by one attribute,
but the server itself uses a different locale.
See `node['database_application']['postgresql']['server_locale']`.

* `node['database_application']['postgresql']['db_locale']`.
Defaults to a platform-specific value.
This attribute applies to all PostgreSQL databases that are created.

Users are enumerated in a hash.
User 'root' can be included to set a password for the root user, otherwise peer authentication is used for root.

* `node['database_application']['database']['users']`.
Defaults to `{}`.
The hash of username to attributes for all database users.
A complete hash would look as below, but all attributes can be omitted.
A user is always granted access to default sources;
additional hosts can be added here.
In addition to defaults for vault_data_bag and vault_bag_item below, vault_item_key will default to username.
```ruby
{
  bud: {
    vault_data_bag: 'passwords',
    vault_bag_item: 'database',
    vault_item_key: 'buds_secret',
    additional_hosts: [
      'db.example.com',
    ],
  },
}
```

The vault location for any password will be defaulted to the values below if not specified.

* `node['database_application']['database']['user_pw']['vault_data_bag']`.
Defaults to `'passwords'`.
The default data bag from which to fetch passwords.

* `node['database_application']['database']['user_pw']['vault_bag_item']`.
Defaults to `'database'`.
The default bag item from which to fetch passwords.

Databases are enumerated in two attributes.

* `node['database_application']['database']['mariadb']`.
Defaults to `[]`.
The list of names of databases to create.

* `node['database_application']['database']['postgresql']`.
Defaults to `[]`.
The list of names of databases to create.
An example is shown below.
The named database will be created,
and the listed users will be granted full privileges on that database from all hosts for that user.
```ruby
{
    db_name: 'secret_db',
    user_names: [
      'sri',
      'bud',
    ],
  }
```

Minimum access for all databases is specified in one attribute.

* `node['database_application']['database']['mariadb_hosts']`.
Defaults to
```ruby
[
  'localhost',
  '127.0.0.1',
]
```
The default hosts from which all users can connect to MariaDB.
If remote access is desired, the FQDN of the server is typically appended to this list.

* `node['database_application']['database']['postgresql_addresses']`.
Defaults to
```ruby
[
  '127.0.0.1/32',
]
```
The default addresses from which all users can connect to PostgeSQL.
If remote access is desired, the FQDN of the server is typically appended to this list.

### backup

If configured, backup files are compressed, timestamped, and then copied to the 'latest' revision.
Thus two artifacts are created,
backup\_{mariadb, postgresql}\_{db_name}\_{timestamp}.sql.7z and
backup\_{mariadb, postgresql}\_{db_name}\_latest.sql.7z.
Both files are copied to S3 if configured to do so.
The local timestamped file may be deleted if configured to do so.

* `node['database_application']['backup']['directory']`.
Defaults to `'/var/opt/database_application/backups'`.
The directory in which to store backups.

Timing of backups is controlled using standard [cron syntax](https://en.wikipedia.org/wiki/Cron).

* `node['database_application']['backup']['weekday']`.
Defaults to `'0'`.
The day of the week to perform backups, starting at 0.

* `node['database_application']['backup']['day']`.
Defaults to `'*'`.
The day of the month to perform backups, starting at 0.

* `node['database_application']['backup']['hour']`.
Defaults to `'6'`.
The hour at which backups are performed.
Time is in UTC.

The attributes below control remote backups.

* `node['database_application']['backup']['copy_to_s3']`.
Defaults to `false`.
If true, backups will be transferred to S3.
If false, the attributes below have no effect.

* `node['database_application']['backup']['delete_local_copy']`.
Defaults to `false`.
If true, the timestamped backup will be deleted after successfully uploading to S3.
A 'latest' backup is always retained.

* `node['database_application']['backup']['s3_path']`.
Defaults to `nil`.
The bucket path in S3, omitting protocol.
For example, `'my-bucket/db-backups'`.

### restore

An attribute controls the databases to restore for each server.
If non-nil, only those databases in the list will be restored.
Otherwise, all databases will be restored.

* `node['database_application']['restore']['database']['mariadb']`.
Defaults to `nil`.

* `node['database_application']['restore']['database']['postgresql']`.
Defaults to `nil`.

## Examples

This is an application cookbook; no custom resources are provided.
See recipes and attributes for details of what this cookbook does.

A sample client cookbook that demonstrates features of this cookbook can be found at test/fixtures/cookbooks/test_harness.

## Development

See CONTRIBUTING.md and TESTING.md.
