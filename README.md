# puppet_metrics_dashboard

- [Description](#Description)
- [Setup](#Setup)
  - [Upgrade notes, breaking changes in v2](#Upgrade-notes-breaking-changes-in-v2)
  - [Determining where Telegraf runs](#Determining-where-Telegraf-runs)
  - [Beginning with puppet_metrics_dashboard](#Beginning-with-puppet_metrics_dashboard)
    - [Minimal configuration](#Minimal-configuration)
- [Usage](#Usage)
  - [To install example dashboards and use the Telegraf collection method (default)](#To-install-example-dashboards-and-use-the-Telegraf-collection-method-default)
  - [Configure Telegraf for one or more masters / PuppetDB nodes / Postgres nodes](#Configure-Telegraf-for-one-or-more-masters--PuppetDB-nodes--Postgres-nodes)
  - [Enable Graphite support](#Enable-Graphite-support)
  - [Enable Telegraf, Graphite, and Archive (puppet_metrics)](#Enable-Telegraf-Graphite-and-Archive-puppet_metrics)
  - [Enable SSL](#Enable-SSL)
  - [Allow access to PE-managed Postgres nodes with the following class](#Allow-access-to-PE-managed-Postgres-nodes-with-the-following-class)
  - [Profile defined types](#Profile-defined-types)
    - [Note on using the defined types](#Note-on-using-the-defined-types)
  - [Other possibilities](#Other-possibilities)
- [Reference](#Reference)
- [Limitations](#Limitations)
  - [Repo failure for InfluxDB packages](#Repo-failure-for-InfluxDB-packages)
  - [Postgres metrics collection requires Telegraf version 1.9.1 or later](#Postgres-metrics-collection-requires-Telegraf-version-191-or-later)
- [Development](#Development)

## Description

This module is used to configure Grafana and InfluxDB to consume metrics from Puppet services.
By default the metrics collection is done by [Telegraf](https://github.com/influxdata/telegraf).

These services can all run on a single server by applying the base class.  You also have the option
to use the [included defined types](#profile-defined-types) to configure Telegraf on each of your Puppet infrastructure components
(master, compilers, PuppetDB, Postgres server) and the metrics will be stored on another server
running Grafana and InfluxDB.  In environments where there is an existing Grafana / InfluxDB
instance, the later option is recommended. See [Determining where Telegraf runs](#determining-where-telegraf-runs) for further
details.

You have the option of collecting metrics using any or all of these methods:

- Through Telegraf, which polls several of Puppet's metrics endpoints (recommended)
- Through Archive files from the [puppetlabs/puppet_metrics_collector](https://forge.puppet.com/puppetlabs/puppet_metrics_collector) module
- Natively, via Puppetserver's [built-in graphite support](https://puppet.com/docs/pe/2019.0/getting_started_with_graphite.html#task-7933)

## Setup

### Upgrade notes, breaking changes in v2

The `puppet_metrics_dashboard::profile::postgres` class is now deprecated and you should use the `puppet_metrics_dashboard::profile::Master::postgres_access` class instead.

Parameters `telegraf_agent_interval` and `http_response_timeout` were previously integers but are now strings.  The value should match a time interval, such as `5s`, `10m`, or `1h`.

`influxdb_urls` was previously a string, it should now be an array.

Previous versions of this module put several `[[inputs.httpjson]]` entries in
`/etc/telegraf/telegraf.conf`. These entries should be removed now as all
module-specific settings now reside in individual files within
`/etc/telegraf/telegraf.d/`. Telegraf will continue to work if you do not remove them, however, the old
`[[inputs.httpjson]]` will not be updated going forward.

### Determining where Telegraf runs

Telegraf can run on the Grafana server or on each Puppet infrastructure node.  To configure Telegraf to run on the same host that
Grafana runs on, use the `puppet_metrics_dashboard` class and the parameters: `master_list`, `puppetdb_list` and `postgres_host_list`.  These parameters determine which hosts that Telegraf polls.

To configure Telegraf to run on each Puppet infrastructure node, use the corresponding profiles for those hosts.  See [Profile defined types](#profile-defined-types).  The `puppet_metrics_dashboard` class is still applied to a separate host to setup Grafana and InfluxDB and the profile classes configure Telegraf when applied to your Puppet infrastructure hosts.

### Beginning with puppet_metrics_dashboard

#### Minimal configuration

Configures Grafana, InfluxDB, and Telegraf, with an InfluxDB datasource and a database called "puppet_metrics"

```puppet
include puppet_metrics_dashboard
```

## Usage

### To install example dashboards and use the Telegraf collection method (default)

```puppet
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
}
```

> `add_dashboard_examples` enforces state on the dashboards. Remove this later if you want to make edits to the examples or add the `overwrite_dashboards` parameter to disable overwriting the dashboards after the first run.

```puppet
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  overwrite_dashboards   => false,
}
```

### Configure Telegraf for one or more masters / PuppetDB nodes / Postgres nodes

```puppet
class { 'puppet_metrics_dashboard':
  master_list         => ['master1.com',
                          # Alternate ports may be configured using
                          # a pair of: [hostname, port_number]
                          ['master2.com', 9140]],
  puppetdb_list       => ['puppetdb1','puppetdb2'],
  postgres_host_list  => ['postgres01','postgres02'],
}
```

### Enable Graphite support

```puppet
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  consume_graphite       => true,
  influxdb_database_name => ["graphite"],
  master_list            => ["master01.example.com","master02.org"],
}
```

* This method requires enabling on the master side as described [here](https://puppet.com/docs/pe/latest/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support).  The hostname(s) that you use in `master_list` should match the value(s) that you used for `metrics_server_id` in the `puppet_enterprise::profile::master` class.

### Enable Telegraf, Graphite, and Archive (puppet_metrics)

```puppet
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
  consume_graphite       => true,
}
```

### Enable SSL

```puppet
class { 'puppet_metrics_dashboard':
  use_dashboard_ssl => true,
}
```

By default, this will create a set of certificates in `/etc/grafana` that are based on Puppet's agent certificates. You can also specify a different location by passing the variables below, but managing the certificate content or supplying your own certificates isn't yet supported.

`dashboard_cert_file` `dashboard_cert_key`

_Note:_ Enabling SSL on Grafana will not allow for running on privileged ports such as `443`. To enable this capability you can use the suggestions documented in [this Grafana documentation](http://docs.grafana.org/installation/configuration/#http-port)

### Allow access to PE-managed Postgres nodes with the following class

This is required for collection of Postgres metrics.  The class should be applied to the master (or Postgres server if using external Postgres).

```puppet
class { 'puppet_metrics_dashboard::profile::master::postgres_access':
  telegraf_host => 'grafana-server.example.com',
}
```

`telegraf_host` is optional.  If you do not specify it, the class will look for a node with the `puppet_metrics_dashboard` class applied in PuppetDB and use the `certname` of the first host returned.  If the PuppetDB lookup fails and you do not specify `telegraf_host` then the class outputs a warning.

### Profile defined types

The module includes defined types that you can use with an existing Grafana implementation. See [REFERENCE.md](REFERENCE.md) for example usage.

#### Note on using the defined types

Because of the way that the Telegraf module works, these examples will overwrite any configuration in `telegraf.conf` if it is *not* already puppet-managed.  See the [puppet-telegraf documentation](https://forge.puppet.com/puppet/telegraf#usage) on how to manage this file and add important settings.

### Other possibilities

Configure the passwords for the InfluxDB and enable additional [TICK Stack](https://www.influxdata.com/time-series-platform/) components.

```puppet
class { 'puppet_metrics_dashboard':
  influx_db_password  => 'secret',
  grafana_http_port   => 8080,
  grafana_version     => '4.5.2',
  enable_chronograf   => true,
  enable_kapacitor    => true,
}
```

## Reference

This module is documented via
`pdk bundle exec puppet strings generate --format markdown`.
Please see [REFERENCE.md](REFERENCE.md) for more info.

## Limitations

### Repo failure for InfluxDB packages

When installing InfluxDB on CentOS/RedHat 6 or 7 you may encounter the following error message. This is due to a mismatch in the ciphers available on the local OS and on the InfluxDB repo.

```puppet
Error: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
Error: /Stage[main]/Pe_metrics_dashboard::Telegraf/Package[telegraf]/ensure: change from purged to present failed: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
```

To rectify the issue, please update `nss` and `curl` on the affected system.

```bash
yum install curl nss --disablerepo influxdb
```

### Postgres metrics collection requires Telegraf version 1.9.1 or later

## Development

Please see CONTRIBUTING.md
