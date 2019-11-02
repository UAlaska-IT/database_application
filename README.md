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

The firewall can be configured for remote access, or not for local databases.

Automated dumps can be setup, as well as automated remote backup to AWS S3.
For remote backup to succeed, the node must be configured with a proper instance profile that provides S3 put privileges for the indicated bucket.

A recovery recipe is included and will recover up to all databases from S3.
For recovery to succeed on a new node that does not have local backups available,
the node must be configured with a proper instance profile that provides S3 get privileges for the indicated bucket.

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
