# ⚠ WARNING ⚠

This Module and Repository has been deprecated and is no longer maintained

For the functional replacement of this module, please see [puppet_operational_dashboards](https://github.com/puppetlabs/puppet_operational_dashboards).


# puppet_metrics_dashboard

- [Description](#description)
- [Setup](#setup)
  - [Upgrade notes](#upgrade-notes)
  - [Determining where Telegraf runs](#determining-where-telegraf-runs)
  - [Requirements](#requirements)
- [Usage](#usage)
  - [Configure a Standard Primary Server and a Dashboard node](#configure-a-standard-primary-server-and-a-dashboard-node)
  - [Manual configuration of a complex Puppet Infrastructure](#manual-configuration-of-a-complex-puppet-infrastructure)
  - [Configure Primary Server, Compiler running PuppetDB and a Dashboard node](#configure-primary-server-compiler-running-puppetdb-and-a-dashboard-node)
  - [Configure Graphite](#configure-graphite)
  - [Configure Telegraf, Graphite, and Archive](#configure-telegraf-graphite-and-archive)
  - [Allow Telegraf to access PE-PostgreSQL](#allow-telegraf-to-access-pe-postgresql)
  - [Enable SSL](#enable-ssl)
  - [Profile defined types](#profile-defined-types)
  - [Other possibilities](#other-possibilities)
  - [Default dashboards](#default-dashboards)
- [Using Archive Metrics](#using-archive-metrics)
  - [Viewing Archive Metrics using Docker](#viewing-archive-metrics-using-docker)
  - [Import Archive Metrics into InfluxDB](#import-archive-metrics-into-influxdb)
- [Reference](#reference)
- [Limitations](#limitations)
  - [Repository failure for InfluxDB packages](#repository-failure-for-influxdb-packages)
  - [PostgreSQL metrics collection with older versions of Telegraf](#postgresql-metrics-collection-with-older-versions-of-telegraf)
  - [Puppet-Telegraf module version 4.0.0](#puppet-telegraf-module-version-400)
- [Development](#development)

## Description

This module is used to configure Telegraf, InfluxDB, and Grafana, and collect, store, and display metrics collected from Puppet services.
By default, those components are installed on a separate Dashboard node by applying the base class of this module to that node.
That class will automatically query PuppetDB for Puppet Infrastructure nodes (Primary server, Compilers, PuppetDB hosts, PostgreSQL hosts) or you can specify them via associated class parameters.
It is not recommended to apply the base class of this module to one of your Puppet Infrastructure nodes.

You have the option to use the [included defined types](#profile-defined-types) to configure Telegraf to run on each Puppet Infrastructure node,
with the metrics being stored and displayed by another node running InfluxDB and Grafana.  
In environments where there is an existing InfluxDB/Grafana installation, this option is recommended.
See [Determining where Telegraf runs](#determining-where-telegraf-runs) for details.

You have the option of collecting metrics using any or all of the following methods:

- Via Telegraf, which polls Puppet service endpoints (default, recommended)
- Via Puppet Server's [built-in Graphite support](https://puppet.com/docs/pe/latest/getting_started_with_graphite.html) (Section: Enabling Puppet Server's Graphite support)
- Via Archive files imported from the [puppetlabs/puppet_metrics_collector](https://forge.puppet.com/puppetlabs/puppet_metrics_collector) module

## Setup

> In PuppetDB 6.9.1 & 5.2.13 and newer, the `/metrics/v1` endpoints are disabled by default and access to the `/metrics/v2` endpoints are restricted to localhost only in response to [CVE-2020-7943](https://nvd.nist.gov/vuln/detail/CVE-2020-7943). 
Starting with version 2.3.0 of this module, PuppetDB metrics will not be setup by the main class if you are on the versions above or higher unless the main class is applied to the Primary Server. To collect PuppetDB metrics in other scenarios, you should use the `puppet_metrics_dashboard::profile::puppetdb` class applied to any PuppetDB nodes with the option `enable_client_cert => false` (the request will be to localhost and doen't require SSL)

### Upgrade notes

* Version 2 and up now requires the `toml-rb` gem installed on the Primary Server and any/all Compilers.
* The `puppet_metrics_dashboard::profile::postgres` class is deprecated in favor of the `puppet_metrics_dashboard::profile::master::postgres_access` class.
* Parameters `telegraf_agent_interval` and `http_response_timeout` were previously Integers but are now Strings. The value should match a time interval, such as `5s`, `10m`, or `1h`.
* `influxdb_urls` was previously a String, but is now an Array.

Previous versions of this module added several `[[inputs.httpjson]]` entries in `/etc/telegraf/telegraf.conf`.
These entries should be removed, as all module-specific settings now reside in individual files within `/etc/telegraf/telegraf.d/`.
Telegraf will continue to work if you do not remove them, however, the old `[[inputs.httpjson]]` will not be updated going forward.

### Determining where Telegraf runs

Telegraf can be configured to run on the Dashboard node, or on each Puppet Infrastructure node.
By default, this module configures Telegraf on the Dashboard node by querying PuppetDB to identify each Puppet Infrastructure node.
To manually configure Telegraf on the Dashboard node, define the following `puppet_metrics_dashboard` class parameters: `master_list`, `puppetdb_list` and `postgres_host_list`.

To configure Telegraf to run on each Puppet Infrastructure node, use the corresponding profiles for those nodes.
See [Profile defined types](#profile-defined-types).
Apply the `puppet_metrics_dashboard` class to the Dashboard node to configure InfluxDB and Grafana, and apply the profile classes on each Puppet Infrastructure node to configure Telegraf.

### Requirements

The [toml-rb](https://github.com/emancu/toml-rb) gem is a requirement of the `puppet-telegraf` module, and needs to be installed in Puppet Server on the Primary Server and any/all Compilers.

Apply the following class to the Primary Server and any/all Compilers to install the gem.

```puppet
node 'primary.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
node 'compiler.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
```

Or, you can apply the `puppet_metrics_dashboard::profile::master::install` class to the `PE Master` Node Group, if using Puppet Enterprise. 

Or, you can manually install the gem using the following command.

```bash
puppetserver gem install toml-rb
```

Restart the Puppet Server service after manually installing the gem.

If you are configuring the Dashboard node via a `puppet apply` workflow, you will need to install the gem into Puppet on that host.

## Usage

### Configure a Standard Primary Server and a Dashboard node

```puppet
node 'primary.example.com' {
  include puppet_metrics_dashboard::profile::master::install
  include puppet_metrics_dashboard::profile::master::postgres_access
}

node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    overwrite_dashboards   => false,
  }
}
```

This will configure Telegraf, InfluxDB, and Grafana on the Dashboard node, and allow Telegraf on that host to access PostgreSQL on the Standard Primary Server.

Note that the `add_dashboard_examples` parameter enforces state on the example dashboards.
Setting the `overwrite_dashboards` parameter to `true` disables overwriting your modifications (if any) to the example dashboards.

### Manual configuration of a complex Puppet Infrastructure

```puppet
node 'primary.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
node 'compiler01.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
node 'compiler02.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
node 'postgres01.example.com' {
  include puppet_metrics_dashboard::profile::master::postgres_access
}
node 'postgres02.example.com' {
  include puppet_metrics_dashboard::profile::master::postgres_access
}

node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    overwrite_dashboards   => false,
    configure_telegraf     => true,
    enable_telegraf        => true,
    master_list            => ['primary.example.com', ['compiler01.example.com', 9140], ['compiler02.example.com', 9140]],
    puppetdb_list          => ['puppetdb01.example.com', 'puppetdb02.example.com'],
    postgres_host_list     => ['postgres01.example.com', 'postgres02.example.com'],
  }
}
# Alternate ports are configured using a pair of: [host_name, port_number]
```

Note that the defaults for this module's class parameters are defined in its `data/common.yaml` directory.

The `*_list` parameters can be defined in the class declaration, or elsewhere in Hiera. For example:

```yaml
puppet_metrics_dashboard::master_list:
  - "primary.example.com"
  - ["compiler01.example.com", 9140]
  - ["compiler02.example.com", 9140]
puppet_metrics_dashboard::puppetdb_list:
  - "puppetdb01.example.com"
  - "puppetdb02.example.com"
puppet_metrics_dashboard::postgres_host_list:
  - "postgres01.example.com"
  - "postgres02.example.com"
```

### Configure Primary Server, Compiler running PuppetDB and a Dashboard node

```puppet
node 'primary.example.com' {
  include puppet_metrics_dashboard::profile::master::install
}
node 'dbcompiler.example.com' {
  class { 'puppet_metrics_dashboard::profile::dbcompiler::install':
    influxdb_urls => ["http://dashboard.example.com:8086"]
  }
}
node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    overwrite_dashboards   => false,
  }
}
```

This will configure Telegraf, InfluxDB, and Grafana on the Dashboard node, and allow Telegraf on that host to access PuppetDB on the Compiler running PuppetDB.

### Configure Graphite

```puppet
node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    overwrite_dashboards   => false,
    consume_graphite       => true,
    influxdb_database_name => ['graphite'],
    master_list            => ['primary', 'compiler01'],
  }
}
```

* This method requires enabling Graphite on the Primary Server and Compilers, as described [here](https://puppet.com/docs/pe/latest/puppet_server_metrics/getting_started_with_graphite.html#enabling-puppet-server-graphite-support).
The hostnames that you use in `master_list` must match the value(s) that you used for `metrics_server_id` in the `puppet_enterprise::profile::master` class.
You must use hostnames rather than fully-qualified domain names (no dots) both in this class and in the  `puppet_enterprise::profile::master` class.

### Configure Telegraf, Graphite, and Archive

Archive refers to files imported from the [puppetlabs/puppet_metrics_collector](https://forge.puppet.com/puppetlabs/puppet_metrics_collector) module.

```puppet
node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    add_dashboard_examples => true,
    overwrite_dashboards   => false,
    configure_telegraf     => true,
    enable_telegraf        => true,
    consume_graphite       => true,
    influxdb_database_name => ['telegraf', 'graphite', 'puppet_metrics'],
  }
}
```

### Allow Telegraf to access PE-PostgreSQL

The following class is required to be applied to the Primary Server (or the PE Database node if using external PostgreSQL) for collection of PostgreSQL metrics via Telegraf.

```puppet
node 'primary.example.com' {
  class { 'puppet_metrics_dashboard::profile::master::postgres_access':
    telegraf_host => 'grafana-server.example.com',
  }
}
```

The `telegraf_host` parameter is optional. 
By default, the class will query PuppetDB for Dashboard nodes (with the `puppet_metrics_dashboard` class applied) and use the `certname` of the first node in the results.
If the PuppetDB lookup fails to find a Dashboard node, and you do not specify `telegraf_host` then the class outputs a warning.

Refer to [Issue 72](https://github.com/puppetlabs/puppet_metrics_dashboard/issues/72) if the above generates the following error:

```
Error: Could not retrieve catalog from remote server: Error 500 on SERVER: Server Error: Evaluation Error: Error while evaluating a Resource Statement, Evaluation Error: Error while evaluating a Function Call, 'versioncmp' parameter 'a' expects a String value, got Undef (file: /opt/puppetlabs/puppet/modules/pe_postgresql/manifests/server/role.pp, line: 66, column: 6) (file: /etc/puppetlabs/code/environments/production/modules/puppet_metrics_dashboard/manifests/profile/master/postgres_access.pp, line: 42) on node primary.example.com
```

A workaround for that error is to apply the `puppet_metrics_dashboard::profile::master::postgres_access` class to the `PE Database` Node Group in the Console, if using Puppet Enterprise. 

### Enable SSL

```puppet
node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    use_dashboard_ssl => true,
  }
}
```

By default, this will create a set of certificates in `/etc/grafana` that are based on the Dashboard node's Puppet agent certificates.
You can also specify different files by defining the `dashboard_cert_file` and `dashboard_cert_key` parameters, but managing certificate content or supplying your own certificates is unsupported by this module.

Note that enabling SSL on Grafana will not allow for running on privileged ports such as `443`.
To enable that capability, use the suggestions documented in [the Grafana documentation](http://docs.grafana.org/installation/configuration/#http-port)

### Profile defined types

The module includes defined types that you can use with an existing Grafana implementation.
See [REFERENCE.md](REFERENCE.md) for example usage.

Note that because of the way that the Telegraf module works, these examples will overwrite any configuration in `telegraf.conf` if it is *not* already managed by Puppet.
See the [puppet-telegraf documentation](https://forge.puppet.com/puppet/telegraf#usage) on how to manage that file and add other settings.

### Other possibilities

Configure the password for InfluxDB , enable additional [TICK Stack](https://www.influxdata.com/time-series-platform/) components, and customize Grafana.

```puppet
node 'dashboard.example.com' {
  class { 'puppet_metrics_dashboard':
    influx_db_password  => 'secret',
    enable_chronograf   => true,
    enable_kapacitor    => true,
    grafana_http_port   => 3333,
    grafana_version     => '6.5.2',
  }
}
```
### Default dashboards

This module comes with a few default dashboards. For reference, please check [Default Dashboards](./files).

## Using Archive Metrics

### Viewing Archive Metrics using Docker

This module comes with a the ability to view archive metrics using [litmus](https://github.com/puppetlabs/puppet_litmus), [Docker](https://www.docker.com/), and [PDK](https://puppet.com/docs/pdk/latest/pdk.html). This process provisions a [Docker](https://www.docker.com/) container with the module applied, and imports `pe_metrics` metrics from the [puppetlabs-puppet_metrics_collector module](https://forge.puppet.com/modules/puppetlabs/puppet_metrics_collector). In order to run this, you need [Docker](https://www.docker.com/) and [PDK](https://puppet.com/docs/pdk/latest/pdk.html) installed on your system.

The following command will provision a local docker container with the local version of this module applied and import the last 30 days of metrics collected by the [puppetlabs-puppet_metrics_collector module](https://forge.puppet.com/modules/puppetlabs/puppet_metrics_collector).

```shell
pdk bundle install
pdk bundle exec rake 'viewer[/path/to/offline/metrics]'
```

The command above will download a CentOS 7 container image configured in the [viewer node-set](./provision.yaml), install Puppet 6.x, copy this module, and apply the module, and import metrics from the specified directory. The UI will be available on <http://localhost:3000> with the default `admin` credentials. This method only uses the `pe_metrics` database and associated dashboards. To limit the number of days to import metrics, an optional day parameter can be passed into the `pdk bundle exec rake 'litmus:viewer[/path/to/offline/metrics,20]'` command.

The following command can be used to import additional metrics into a running instance.

```shell
pdk bundle exec rake 'viewer:import[/path/to/offline/metrics]'
```

The following command can be run to destroy the local instance.

```shell
pdk bundle exec rake viewer:destroy
```

### Import Archive Metrics into InfluxDB

The `json2timeseriesdb` script from the [puppetlabs/puppet_metrics_collector](https://forge.puppet.com/puppetlabs/puppet_metrics_collector) module can be used to transform its data and import it into InfluxDB.

Examples:

```bash
./json2timeseriesdb /opt/puppetlabs/puppet-metrics-collector/puppetserver/*/*.json --convert-to influxdb --influx-db puppet_metrics --netcat dashboard.example.com
```

This simple example can be used for small number of files. For a large number of files, use `--pattern`.

```bash
./json2timeseriesdb  --pattern '/opt/puppetlabs/puppet-metrics-collector/puppetserver/*/*.json' --convert-to influxdb --influx-db puppet_metrics --netcat dashboard.example.com
```

The `--pattern` flag accepts a Ruby glob argument, which the script will internally expand into a list of files.

## Reference

This module is documented via `pdk bundle exec puppet strings generate --format markdown`.
Please refer to [REFERENCE.md](REFERENCE.md) for more information.

## Limitations

### Repository failure for InfluxDB packages

When installing InfluxDB on CentOS/RedHat 6/7 you may encounter the following error message.

```puppet
Error: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
Error: /Stage[main]/Puppet_metrics_dashboard::Telegraf/Package[telegraf]/ensure: change from purged to present failed: Execution of '/usr/bin/yum -d 0 -e 0 -y install telegraf' returned 1: Error: Cannot retrieve repository metadata (repomd.xml) for repository: influxdb. Please verify its path and try again
```

This is due to a mismatch in the ciphers available in the operating system and on the InfluxDB repository.
To resolve this issue, update `nss` and `curl` on the Dashboard node.

```bash
yum install curl nss --disablerepo influxdb
```

### PostgreSQL metrics collection with older versions of Telegraf

PostgreSQL metrics collection requires Telegraf version 1.9.1 or later.

### Puppet-Telegraf module version 4.0.0

This module is not compatible with `puppet-telegraf` version 4.0.0. Please use 3.x or 4.1+. See (#158)[https://github.com/puppetlabs/puppet_metrics_dashboard/issues/158] for more details.

## Development

Please refer to [CONTRIBUTING.md](CONTRIBUTING.md) for more information.
