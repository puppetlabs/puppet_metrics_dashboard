# pe_metrics_dashboard

#### Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with pe_metrics_dashboard](#setup)
    * [What pe_metrics_dashboard affects](#what-pe_metrics_dashboard-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with pe_metrics_dashboard](#beginning-with-pe_metrics_dashboard)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Description

This module is used to configure grafana, telegraf, and influxdb to consume metrics from Puppet Enterprise.  

You have the option of getting metrics from any or all of three of these methods:

* the [npwalker/pe_metric_curl_cron_jobs](https://forge.puppet.com/npwalker/pe_metric_curl_cron_jobs) module 
* Natively, via Puppetserver's [built-in graphite support](https://puppet.com/docs/pe/2017.3/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support)
* Through telegraf, which polls several of PE's metrics endpoints

## Setup

### Beginning with pe_metrics_dashboard

#### Minimal configuration 

Configures grafana-server, influxdb, and telegraf, with an influxdb datasource and a database called "pe_metrics"

```
include pe_metrics_dashboard::install
```

## Usage

#### To install example dashboards for each of the collection methods:

```
class { 'pe_metrics_dashboard::install':
  add_dashboard_examples => true,
  influxdb_database_name => ['pe_metrics','telegraf','graphite'],
}
```

*add_dashboard_examples enforces state on the dashboards.  Remove this later if you want to make edits to the examples.

#### Configure telegraf for one or more masters / puppetdb nodes:

```
class { 'pe_metrics_dashboard::install':
  configure_telegraf  => true,
  master_list         => ['master1.com','master2.com'],
  puppetdb_list       => ['puppetdb1','puppetdb2'],
}
```

#### Enable Graphite support 

```
class { 'pe_metrics_dashboard::install':
  consume_graphite   => true,
}
```

*requires enabling on the master side as described [here](https://puppet.com/docs/pe/2017.3/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support)

#### Other possibilities

```
class { 'pe_metrics_dashboard::install':
  influx_db_password  => 'secret',
  grafana_password    => 'secret',
  grafana_http_port   => 8080,
  grafana_version     => '4.5.2',
  enable_chronograf   => true,
  enable_kapacitor    => true,
}
```

## Reference

## Limitations

## Development
