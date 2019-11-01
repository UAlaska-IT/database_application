# Database Application Cookbook

__Maintainer: OIT Systems Engineering__ (<ua-oit-se@alaska.edu>)

## Purpose

This cookbook configures a multi-database server.
Both MariaDB and PostgreSQL can be installed and databases created from a list in attributes.

The firewall can be configured for remote access, or not for local databases.

Automated dumps can be setup, as well as remote backup to AWS S3.
For remote backup to succeed, the node must be configured with a proper instance profile.

## Requirements

### Chef

This cookbook requires Chef 14+

### Platforms

Supported Platform Families:

* Debian
  * Ubuntu, Mint
* Red Hat Enterprise Linux
  * Amazon, CentOS, Oracle

Platforms validated via Test Kitchen:

* Ubuntu
* CentOS

### Dependencies

This cookbook does not constrain its dependencies because it is intended as a utility library.
It should ultimately be used within a wrapper cookbook.

## Resources

This cookbook provides no custom resources.

## Recipes

### database_application::default

This recipe configures a webserver and database.

### database_application::restore

If a both a local database is configured and backups are configured,
this recipe will restore the database from the latest snapshot.
Otherwise does nothing.

## Attributes

### default

### app

### database

### install

## Examples

This is an application cookbook; no custom resources are provided.
See recipes and attributes for details of what this cookbook does.

## Development

See CONTRIBUTING.md and TESTING.md.
