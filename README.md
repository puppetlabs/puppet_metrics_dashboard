# pe_metrics_dashboard

## Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with pe_metrics_dashboard](#setup)
  * [What pe_metrics_dashboard affects](#what-pe_metrics_dashboard-affects)
  * [Setup requirements](#setup-requirements)
  * [Beginning with pe_metrics_dashboard](#beginning-with-pe_metrics_dashboard)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

This module is used to configure grafana, telegraf, and influxdb to consume metrics from Puppet Enterprise.

You have the option of getting metrics from any or all of three of these methods:

* Through Archive files from the [npwalker/pe_metric_curl_cron_jobs](https://forge.puppet.com/npwalker/pe_metric_curl_cron_jobs) module
* Natively, via Puppetserver's [built-in graphite support](https://puppet.com/docs/pe/2017.3/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support)
* Through telegraf, which polls several of PE's metrics endpoints

## Setup

### Beginning with pe_metrics_dashboard

#### Minimal configuration

Configures grafana-server, influxdb, and telegraf, with an influxdb datasource and a database called "pe_metrics"

```
include pe_metrics_dashboard
```

## Usage

### To install example dashboards for all of the collection methods:

```
class { 'pe_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['pe_metrics','telegraf','graphite'],
}
```

* `add_dashboard_examples` enforces state on the dashboards. Remove this later if you want to make edits to the examples or add the `overwrite_dashboards` parameter to disable overwriting the dashboards after the first run.

```
class { 'pe_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['pe_metrics','telegraf','graphite'],
  overwrite_dashboards   => false,
}
```

### Configure telegraf for one or more masters / puppetdb nodes:

```
class { 'pe_metrics_dashboard':
  configure_telegraf  => true,
  enable_telegraf     => true,
  master_list         => ['master1.com','master2.com'],
  puppetdb_list       => ['puppetdb1','puppetdb2'],
}
```

### Enable Graphite support

```
class { 'pe_metrics_dashboard':
  add_dashboard_examples => true,
  consume_graphite       => true,
  influxdb_database_name => ["graphite"],
  master_list            => ["master01.example.com","master02.org"],
}
```

* This method requires enabling on the master side as described [here](https://puppet.com/docs/pe/2017.3/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support).  The hostname(s) that you use in `master_list` should match the value(s) that you used for `metrics_server_id` in the `puppet_enterprise::profile::master` class. 

### Enable Telegraf, Graphite, and Archive

```
class { 'pe_metrics_dashboard':
  add_dashboard_examples => true,
  influxdb_database_name => ['pe_metrics','telegraf','graphite'],
  consume_graphite       => true,
  configure_telegraf     => true,
  enable_telegraf        => true,
}
```

### Enable SSL

```
class { 'pe_metrics_dashboard':
  use_dashboard_ssl => true,
}
```

By default, this will create a set of certificates in `/etc/grafana` that are based on Puppet's agent certificates. You can also specify a different location by passing the variables below, but managing the certificate content or supplying your own certificates isn't yet supported.

`dashboard_cert_file` `dashboard_cert_key`

_Note:_ Enabling SSL on Grafana will not allow for running on privileged ports such as `443`. To enable this capability you can use the suggestions documented in [this Grafana documentation](http://docs.grafana.org/installation/configuration/#http-port)

### Other possibilities

Configure the passwords for the InfluxDB and Grafana administrator users and enable additional [TICK Stack](https://www.influxdata.com/time-series-platform/) components.

```
class { 'pe_metrics_dashboard':
  influx_db_password  => 'secret',
  grafana_password    => 'secret',
  grafana_http_port   => 8080,
  grafana_version     => '4.5.2',
  enable_chronograf   => true,
  enable_kapacitor    => true,
}
```

## Reference

### Classes

#### Public classes

* [`pe_metrics_dashboard`](#pe_metrics_dashboard): Installs and configures the Puppet Grafana dashboards and underlying connections.

#### Private classes

* [`pe_metrics_dashboard::install`](#pe_metrics_dashboardinstall): Installs and configures the Puppet Grafana dashboards and underlying connections.

### Parameters

#### pe_metrics_dashboard

##### add_dashboard_examples

Whether to add the Grafana dashboard example dashboards for the configured InfluxDB databases.

Valid values are `true`, `false`.

Defaults to `false`.

*Note:* These dashboards are managed and any changes will be overwritten unless the `overwrite_dashboards` is set to `false`.

##### dashboard_cert_file

The location of the Grafana certficiate.

Defaults to `"/etc/grafana/${clientcert}_cert.pem"`

##### dashboard_cert_key

The location of the Grafana private key.

Defaults to `"/etc/grafana/${clientcert}_key.pem"`

##### configure_telegraf

Whether to configure the telegraf service.

Valid values are `true`, `false`.

Defaults to `false`

This parameter enables configuring telegraf to query the `master_list` and `puppetdb_list` endpoints for metrics. Metrics will be stored in the `telegraf` database in InfluxDb. Ensure that `influxdb_database_name` contains `telegraf` when using this parameter.

_Note:_ This parameter is only used if `enable_telegraf` is set to true.

##### consume_graphite

Whether to enable the InfluxDB Graphite plugin.

Valid values are `true`, `false`.

Defaults to `false`

This parameter enables the Graphite plugin for InfluxDB to allow for injesting Graphite metrics. Ensure `influxdb_database_name` contains `graphite` when using this parameter.

*Note:* If using Graphite metrics from the Puppet Master, this needs to be set to `true`.

##### grafana_http_port

The port to run Grafana on.

Valid values are Integers from `1024` to `65536`.

Defaults to `3000`

The grafana port for the web interface. This should be a nonprivileged port (above 1024).

_Note:_ Grafana will not run on privileged ports such as `443`. To enable this capability you can use the suggestions documented in [this Grafana documentation](http://docs.grafana.org/installation/configuration/#http-port)

##### grafana_password

The password for the Grafana admin user.

Defaults to `'admin'`

##### grafana_version

The grafana version to install.

Valid values are String versions of Grafana.

Defaults to `'4.5.2'`

##### influxdb_database_name

An array of databases that should be created in InfluxDB.

Valid values are 'pe_metrics','telegraf', 'graphite', and any other string.

Defaults to `['pe_metrics']`

Each database in the array will be created in InfluxDB. 'pe_metrics','telegraf', and 'graphite' are specially named and will be used with their associated metric collection method. Any other database name will be created, but not utilized with components in this module.

##### influx_db_password

The password for the InfluxDB admin user.

Defaults to `'puppet'`

##### enable_kapacitor

Whether to install kapacitor.

Valid values are `true`, `false`.

Defaults to `false`

Install kapacitor. No configuration of kapacitor is included at this time.

##### enable_chronograf

Whether to install chronograf.

Valid values are `true`, `false`.

Defaults to `false`

Installs chronograf. No configuration of chronograf is included at this time.

##### enable_telegraf

Whether to install telegraf.

Valid values are `true`, `false`.

Defaults to `false`

Installs telegraf. No configuration is done unless the `configure_telegraf` parameter is set to `true`.

##### master_list

An array of Puppet Master servers to collect metrics from.

Defaults to `["$::settings::certname"]`

A list of Puppet master servers that will be configured for telegraf to query.

##### overwrite_dashboards

Whether to overwrite the example Grafana dashboards.

Valid values are `true`, `false`.

Defaults to `false`

This paramater disables overwriting the example Grafana dashboards. It takes effect after the second Puppet run and popultes the `overwrite_dashboards_disabled` fact. This only takes effect when `add_dashboard_examples` is set to true.

##### puppetdb_list

An array of PuppetDB servers to collect metrics from.

Defaults to `["$::settings::certname"]`

A list of PuppetDB servers that will be configured for telegraf to query.

##### use_dashboard_ssl

Whether to enable SSL on Grafana.

Valid values are `true`, `false`.

Defaults to `false`

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


## Development
