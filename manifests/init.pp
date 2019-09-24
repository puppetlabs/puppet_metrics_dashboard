# @summary Installs and configures Grafana with InfluxDB for monitoring Puppet infrastructure.
#
# The puppet_metrics_dashboard module installs and configures an InfluxDB stack
# monitor the Puppet infrastructure components.
#
# @param add_dashboard_examples
#   Whether to add the Grafana dashboard example dashboards for the configured InfluxDB databases.
#   Valid values are `true`, `false`. Defaults to `false`.
#   _Note_: These dashboards are managed and any changes will be overwritten unless the `overwrite_dashboards` is set to `false`.
#
# @param manage_repos
#   Whether or not to setup yum / apt repositories for the dependent packages
#   Valid values are `true`, `false`. Defaults to `true`
#
# @param dashboard_cert_file
#   The location of the Grafana certficiate.
#   Defaults to `"/etc/grafana/${clientcert}_cert.pem"`
#   Only used when configuring `use_dashboard_ssl` is true.
#
# @param dashboard_cert_key
#   The location of the Grafana private key.
#   Defaults to `"/etc/grafana/${clientcert}_key.pem"`
#   Only used when configuring `use_dashboard_ssl` is true.
#
# @param configure_telegraf
#   Whether to configure the telegraf service.
#   Valid values are `true`, `false`. Defaults to `true`
#   This parameter enables configuring telegraf to query the `master_list` and `puppetdb_list` endpoints for metrics. Metrics will be stored
#   in the `telegraf` database in InfluxDb. Ensure that `influxdb_database_name` contains `telegraf` when using this parameter.
#   _Note:_ This parameter is only used if `enable_telegraf` is set to true.
#
# @param consume_graphite
#   Whether to enable the InfluxDB Graphite plugin.
#   Valid values are `true`, `false`. Defaults to `false`
#   This parameter enables the Graphite plugin for InfluxDB to allow for injesting Graphite metrics. Ensure `influxdb_database_name`
#   contains `graphite` when using this parameter.
#   _Note:_ If using Graphite metrics from the Puppet Master, this needs to be set to `true`.
#
# @param grafana_http_port
#   The port to run Grafana on.
#   Valid values are Integers from `1024` to `65536`. Defaults to `3000`
#   The grafana port for the web interface. This should be a nonprivileged port (above 1024).
#
# @param grafana_password
#   The password for the Grafana admin user.
#   Defaults to `'admin'`
#
# @param grafana_version
#   The grafana version to install.
#   Valid values are String versions of Grafana. Defaults to `'4.5.2'`
#
# @param influxdb_database_name
#   An array of databases that should be created in InfluxDB.
#   Valid values are 'puppet_metrics','telegraf', 'graphite', and any other string. Defaults to `['puppet_metrics']`
#   Each database in the array will be created in InfluxDB. 'puppet_metrics','telegraf', and 'graphite' are specially named and will
#   be used with their associated metric collection method. Any other database name will be created, but not utilized with
#   components in this module.
#
# @param influx_db_password
#   The password for the InfluxDB admin user.
#   Defaults to `'puppet'`
#
# @param enable_kapacitor
#   Whether to install kapacitor.
#   Valid values are `true`, `false`. Defaults to `false`
#   Install kapacitor. No configuration of kapacitor is included at this time.
#
# @param enable_chronograf
#   Whether to install chronograf.
#   Valid values are `true`, `false`. Defaults to `false`
#   Installs chronograf. No configuration of chronograf is included at this time.
#
# @param enable_telegraf
#   Whether to install telegraf.
#   Valid values are `true`, `false`. Defaults to `false`
#   Installs telegraf. No configuration is done unless the `configure_telegraf` parameter is set to `true`.
#
# @param master_list
#   A list of Puppet Master servers that Telegraf will be configured to
#   collect metrics from. Entries in the list may be:
#     - A single string that contains a hostname or IP address.
#       The module will use a default port number of 8140.
#     - A list of length two, where the first entry is a string that
#       contains a hostname or IP address and the second entry is an
#       integer that specifies the port number.
#   Defaults to `[$trusted['certname']]`
#
# @param puppetdb_metrics
#   An array of hashes containing name / url pairs for each puppetdb metric.
#   See functions/puppetdb_metrics.pp for defaults.
#
# @param influxdb_urls
#   An array for telegraf's config defining where influxdb instances are
#
# @param telegraf_db_name
#   The database in influxdb where telefraf metrics are stored
#
# @param telegraf_agent_interval
#   How often the telefraf agent queries for metrics.  Defaults to "5s"
#
# @param http_response_timeout
#   How long to wait for the queries by telegraf to finish before giving up. Defaults to "5s"
#
# @param pg_query_interval
#   How often postgres queries will run when monitoring a postgres host. Defaults to "10m"
#
# @param overwrite_dashboards
#   Whether to overwrite the example Grafana dashboards.
#   Valid values are `true`, `false`. Defaults to `false`
#   This paramater disables overwriting the example Grafana dashboards. It takes effect after the second Puppet run and popultes the
#   `overwrite_dashboards_disabled` fact. This only takes effect when `add_dashboard_examples` is set to true.
#
# @param puppetdb_list
#   A list of PuppetDB servers that Telegraf will be configured to
#   collect metrics from. Entries in the list may be:
#     - A single string that contains a hostname or IP address.
#       The module will use a default port number of 8081.
#     - A list of length two, where the first entry is a string that
#       contains a hostname or IP address and the second entry is an
#       integer that specifies the port number.
#   Defaults to `[$trusted['certname']]`
#
# @param postgres_host_list
#   A list of PostgreSQL servers that Telegraf will be configured to
#   collect metrics from. Entries in the list may be:
#     - A single string that contains a hostname or IP address.
#       The module will use a default port number of 5432.
#     - A list of length two, where the first entry is a string that
#       contains a hostname or IP address and the second entry is an
#       integer that specifies the port number.
#   Defaults to `[$trusted['certname']]`
#
# @param use_dashboard_ssl
#   Whether to enable SSL on Grafana.
#   Valid values are `true`, `false`. Defaults to `false`
#
# @param overwrite_dashboards_file
#   File in use to populate the overwrite_dashboards fact
#
# @param influx_db_service_name
#   Name of the influxdb service for the operating system
#
# @param grafana_config
#   Hash of arbitrary config to pass to grafana, this is placed in the
#   grafana.ini file with top-level keys becoming sections and their
#   key-value children becoming settings.
#
# @example Default Configuration
#   include puppet_metrics_dashboard
#
# @example Default Configuration with no login
#   class { 'puppet_metrics_dashboard':
#     grafana_config => {
#       'users'          => {
#         'allow_sign_up' => false,
#       },
#       'auth.anonymous' => {
#         'enabled' => true,
#       },
#     },
#   }
#
# @example Configure Telegraf on a list of masters and PuppetDB servers
#   class { 'puppet_metrics_dashboard':
#     configure_telegraf  => true,
#     enable_telegraf     => true,
#     master_list         => ['master1.com',
#                             # Alternate ports may be configured using
#                             # a list of: `[hostname, port_number]`
#                             ['master2.com', 9140]],
#     puppetdb_list       => ['puppetdb1',
#                             ['puppetdb2', 8100]],
#   }
#
# @example Install example dashboards for all of the collection methods
#   class { 'puppet_metrics_dashboard':
#     add_dashboard_examples => true,
#     influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
#   }
#
# @example Configure telegraf for one or more masters / puppetdb nodes
#   class { 'puppet_metrics_dashboard':
#     configure_telegraf  => true,
#     enable_telegraf     => true,
#     master_list         => ['master1.com','master2.com'],
#     puppetdb_list       => ['puppetdb1','puppetdb2'],
#   }
#
# @example Enable Graphite support
#   class { 'puppet_metrics_dashboard':
#     add_dashboard_examples => true,
#     consume_graphite       => true,
#     influxdb_database_name => ["graphite"],
#     master_list            => ["master01.example.com","master02.org"],
#   }
#
# @example Enable Telegraf, Graphite, and Archive
#  class { 'puppet_metrics_dashboard':
#    add_dashboard_examples => true,
#    influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
#    consume_graphite       => true,
#    configure_telegraf     => true,
#    enable_telegraf        => true,
#  }
#
# @example Enable SSL
#   class { 'puppet_metrics_dashboard':
#     use_dashboard_ssl => true,
#   }
#
class puppet_metrics_dashboard (
  Boolean $add_dashboard_examples,
  Boolean $manage_repos,
  Boolean $use_dashboard_ssl,
  String $dashboard_cert_file,
  String $dashboard_cert_key,
  Boolean $overwrite_dashboards,
  String $overwrite_dashboards_file,
  String $influx_db_service_name,
  Array[String] $influxdb_database_name,
  String $grafana_version,
  Integer $grafana_http_port,
  String $influx_db_password,
  String $grafana_password,
  Boolean $enable_kapacitor,
  Boolean $enable_chronograf,
  Boolean $enable_telegraf,
  Boolean $configure_telegraf,
  Boolean $consume_graphite,
  Puppet_metrics_dashboard::HostList $master_list,
  Puppet_metrics_dashboard::HostList $puppetdb_list,
  Puppet_metrics_dashboard::HostList $postgres_host_list,
  Array[String] $influxdb_urls,
  String $telegraf_db_name,
  String[2] $telegraf_agent_interval,
  String[2] $http_response_timeout,
  String[2] $pg_query_interval,
  Hash $grafana_config,
  Puppet_metrics_dashboard::Puppetdb_metric $puppetdb_metrics = puppet_metrics_dashboard::puppetdb_metrics(),
  ) {
  unless $facts['os']['family'] =~ /^(RedHat|Debian)$/ {
    fail("${facts['os']['family']} installation not supported")
  }

  if $manage_repos {
    contain puppet_metrics_dashboard::repos
    Class['puppet_metrics_dashboard::repos']
    -> Class['puppet_metrics_dashboard::install']
  }

  contain puppet_metrics_dashboard::install
  contain puppet_metrics_dashboard::config
  contain puppet_metrics_dashboard::service
  contain puppet_metrics_dashboard::post_start_configs

  Class['puppet_metrics_dashboard::install']
  -> Class['puppet_metrics_dashboard::config']
  -> Class['puppet_metrics_dashboard::service']
  -> Class['puppet_metrics_dashboard::post_start_configs']

  contain puppet_metrics_dashboard::grafana
  Class['puppet_metrics_dashboard::service']
  -> Class['puppet_metrics_dashboard::grafana']

  if $add_dashboard_examples {
    contain puppet_metrics_dashboard::dashboards
  }

  # Enable Telegraf if `configure_telegraf` is true.
  $_enable_telegraf = $configure_telegraf ? {
    true    => true,
    default => $enable_telegraf
  }

  if $_enable_telegraf {
    contain puppet_metrics_dashboard::telegraf
  }
}
