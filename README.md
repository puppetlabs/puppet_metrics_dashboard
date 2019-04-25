# puppet_metrics_dashboard

## Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with puppet_metrics_dashboard](#setup)
  * [Upgrade note](#upgrade-note)
  * [Beginning with puppet_metrics_dashboard](#beginning-with-puppet_metrics_dashboard)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module is used to configure grafana, telegraf, and influxdb to consume metrics from Puppet service.

You have the option of getting metrics from any or all of three of these methods:

* Through Archive files from the [puppetlabs/puppet_metrics_collector](https://forge.puppet.com/puppetlabs/puppet_metrics_collector) module
* Natively, via Puppetserver's [built-in graphite support](https://puppet.com/docs/pe/2019.0/getting_started_with_graphite.html#task-7933)
* Through telegraf, which polls several of Puppet's metrics endpoints

## Setup

### Upgrade note

Previous versions of this module put several `[[inputs.httpjson]]` entries in
`/etc/telegraf/telegraf.conf`. These entries should be removed now as all
module-specific settings now reside in
`/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf`. Telegraf will
continue to work if you do not remove them, however, the old 
`[[inputs.httpjson]]` will not be updated going forward.


### Beginning with puppet_metrics_dashboard

#### Minimal configuration

Configures grafana-server, influxdb, and telegraf, with an influxdb datasource and a database called "puppet_metrics"

```
include puppet_metrics_dashboard
```

## Usage

### To install example dashboards for all of the collection methods:

```
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
}
```

* `add_dashboard_examples` enforces state on the dashboards. Remove this later if you want to make edits to the examples or add the `overwrite_dashboards` parameter to disable overwriting the dashboards after the first run.

```
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
  overwrite_dashboards   => false,
}
```

### Configure telegraf for one or more masters / puppetdb nodes / postgres nodes:

```
class { 'puppet_metrics_dashboard':
  configure_telegraf  => true,
  enable_telegraf     => true,
  master_list         => ['master1.com',
                          # Alternate ports may be configured using
                          # a pair of: [hostname, port_number]
                          ['master2.com', 9140]],
  puppetdb_list       => ['puppetdb1','puppetdb2'],
  postgres_host_list  => ['postgres01','postgres02'],
}
```

### Allow access to PE-managed postgres nodes with the following class:

This is required for collection of postgres metrics.

```
class { 'puppet_metrics_dashboard::profile::postgres':
  grafana_host => 'postgres01',
}
```

`grafana_host` is optional.  If you do not specify it, the class will look for a node with the `puppet_metrics_dashboard` class applied in PuppetDB and use the `certname` of the first host returned.  If the PuppetDB lookup fails and you do not specify `grafana_host` then the class outputs a warning.

### Enable Graphite support

```
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  consume_graphite       => true,
  influxdb_database_name => ["graphite"],
  master_list            => ["master01.example.com","master02.org"],
}
```

* This method requires enabling on the master side as described [here](https://puppet.com/docs/pe/2017.3/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support).  The hostname(s) that you use in `master_list` should match the value(s) that you used for `metrics_server_id` in the `puppet_enterprise::profile::master` class. 

### Enable Telegraf, Graphite, and Archive

```
class { 'puppet_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
  consume_graphite       => true,
  configure_telegraf     => true,
  enable_telegraf        => true,
}
```

### Enable SSL

```
class { 'puppet_metrics_dashboard':
  use_dashboard_ssl => true,
}
```

By default, this will create a set of certificates in `/etc/grafana` that are based on Puppet's agent certificates. You can also specify a different location by passing the variables below, but managing the certificate content or supplying your own certificates isn't yet supported.

`dashboard_cert_file` `dashboard_cert_key`

_Note:_ Enabling SSL on Grafana will not allow for running on privileged ports such as `443`. To enable this capability you can use the suggestions documented in [this Grafana documentation](http://docs.grafana.org/installation/configuration/#http-port)

### Other possibilities

Configure the passwords for the InfluxDB and Grafana administrator users and enable additional [TICK Stack](https://www.influxdata.com/time-series-platform/) components.

```
class { 'puppet_metrics_dashboard':
  influx_db_password  => 'secret',
  grafana_password    => 'secret',
  grafana_http_port   => 8080,
  grafana_version     => '4.5.2',
  enable_chronograf   => true,
  enable_kapacitor    => true,
}
```

## Reference

**Note** This section is no longer maintained. Please see the REFERENCE.MD file for current listings. 

## Limitations

### Repo failure for InfluxDB packages
When installing InfluxDB on Centos/RedHat 6 or 7 you may encounter the following error message. This is due to a mismatch in the ciphers available on the local OS and on the InfluxDB repo.

```
Error: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
Error: /Stage[main]/Pe_metrics_dashboard::Telegraf/Package[telegraf]/ensure: change from purged to present failed: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
```

To recify the issue, please update `nss` and `curl` on the affected system.

```
yum install curl nss --disablerepo influxdb
```

### Postgres metrics collection requires telegraf version 1.9.1 or later

## Development

Please see CONTRIBUTING.md
