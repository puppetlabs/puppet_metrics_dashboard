# @summary Installs and configures a stack for collecting, storing, and displaying Puppet Infrastructure metrics
#
# Installs and configures a stack for collecting, storing, and displaying Puppet Infrastructure metrics.
# Refer to `data/common.yaml` for additional parameter defaults.
#
# @param [Boolean] manage_repos
#   Whether to configure apt / yum repositories for required packages.
#
# @param [Boolean] add_dashboard_examples
#   Whether to add the example Grafana dashboards for the configured InfluxDB databases. Defaults to `false`.
#   _Note_: These dashboards are managed and any changes will be overwritten unless the `overwrite_dashboards` is set to `false`.
#
# @param [Boolean] overwrite_dashboards
#   Whether to overwrite the example Grafana dashboards. Defaults to `true`
#   This parameter disables overwriting the example Grafana dashboards.
#   It takes effect after the second Puppet run, and populates a `overwrite_dashboards_disabled` fact. 
#   Only used when `add_dashboard_examples` is `true`.
#
# @param [Boolean] enable_chronograf
#   Whether to install chronograf. Defaults to `false`
#   No configuration of chronograf is included at this time.
#
# @param [Boolean] enable_kapacitor
#   Whether to install kapacitor. Defaults to `false`
#   No configuration of kapacitor is included at this time.
#
# @param [Boolean] enable_telegraf
#   Whether to install telegraf. Defaults to `true`
#   No configuration is done unless `configure_telegraf` is set to `true`.
#
# @param [Boolean] configure_telegraf
#   Whether to configure the Telegraf service. Defaults to `true`
#   This parameter enables and configures Telegraf to query the `*_list` hosts for metrics.
#   Metrics will be stored in the `telegraf` database in InfluxDb.
#   Ensure that `influxdb_database_name` contains `telegraf` when using this parameter.
#   Only used when `enable_telegraf` is `true`.
#
# @param [Boolean] consume_graphite
#   Whether to enable the InfluxDB Graphite plugin. Defaults to `false`
#   This parameter enables the Graphite plugin for InfluxDB to allow for consuming Graphite metrics.
#   Ensure `influxdb_database_name` contains `graphite` when using this parameter.
#   _Note:_ To consume metrics sent from Puppet Server, this must to be set to `true`.
#
# @param influxdb_database_name
#   An Array of databases that should be created in InfluxDB.
#   Valid values are `telegraf`, `graphite`, `puppet_metrics`, and any other string. Defaults to `["telegraf"]`
#   Each database in the array will be created in InfluxDB. 
#   `telegraf`, `graphite`, and `puppet_metrics` are specially named and will be used with their associated metric collection method.
#   Any other database name will be created, but not associated with components in this module.
#
# @param influxdb_urls
#   An Array containing urls defining InfluxDB instances for Telegraf.
#
# @param influx_db_service_name
#   Name of the InfluxDB service used by the operating system.
#
# @param influx_db_password
#   The password for the InfluxDB `admin` user.
#   Defaults to `puppet`
#
# @param telegraf_db_name
#   The InfluxDB database where Telegraf metrics are stored.
#
# @param http_response_timeout
#   Timeout for Telegraf HTTP requests. Defaults to `5s`
#
# @param telegraf_agent_interval
#   Frequency of Telegraf HTTP queries for metrics. Defaults to `5s`
#
# @param pg_query_interval
#   Frequency of Telegraf PostgreSQL queries for metrics. Defaults to `10m`
#
# @param use_dashboard_ssl
#   Whether to enable SSL in Grafana.
#   Valid values are `true`, `false`. Defaults to `false`
#
# @param tidy_telegraf_configs
#   Whether or not to remove unmanaged configuration files from `/etc/telegraf/telegraf.d`. Defaults to `false`
#
# @param dashboard_cert_file
#   The location of the Grafana certficiate.
#   Defaults to `/etc/grafana/${clientcert}_cert.pem`
#   Only used when `use_dashboard_ssl` is `true`.
#
# @param dashboard_cert_key
#   The location of the Grafana private key.
#   Defaults to `/etc/grafana/${clientcert}_key.pem`
#   Only used when `use_dashboard_ssl` is `true`.
#
# @param enable_ldap_auth
#   Whether to enable LDAP authentication in Grafana
#   Valid values are `true`, `false`. Defaults to `false`
#
# @param grafana_http_port
#   The port for the Grafana web interface.
#   Valid values are Integers from `1024` to `65536`. Defaults to `3000`
#   This should be a nonprivileged port (above 1024).
#
# @param grafana_password
#   The password for the Grafana `admin` user.
#   Defaults to `admin`
#
# @param grafana_version
#   The version of Grafana to install.
#   Valid values are String versions of Grafana.
#
# @param overwrite_dashboards_file
#   File used to populate the `overwrite_dashboards` fact.
#
# @param grafana_config
#   Hash of arbitrary configuration settings to pass to Grafana.
#   These are added to `grafana.ini` with top-level keys becoming sections and their key-value children becoming settings.
#
# @example Grafana with no login
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
# @param pe_server_list
#   An Array of servers that Telegraf will collect Puppet Server metrics from. 
#   Entries may be:
#     - A String that contains a hostname or IP address.
#       (The module will use a default port number of `8140`)
#     - An Array where the first entry is a String that contains a hostname or IP address,
#       and the second entry is an Integer that specifies the port number.
#   Defaults to the result of a PuppetDB query, or `[$trusted['certname']]`
#
# @param puppetdb_list
#   An Array of servers that Telegraf will collect PuppetDB metrics from. 
#   Entries may be:
#     - A String that contains a hostname or IP address.
#       (The module will use a default port number of `8081`)
#     - An Array where the first entry is a String that contains a hostname or IP address,
#       and the second entry is an Integer that specifies the port number.
#   Defaults to the result of a PuppetDB query, or `[$trusted['certname']]`
#
# @param postgres_host_list
#   An Array of servers that Telegraf will collect PostgreSQL metrics from. 
#   Entries may be:
#     - A String that contains a hostname or IP address.
#       (The module will use a default port number of `5432`)
#     - An Array where the first entry is a String that contains a hostname or IP address,
#       and the second entry is an Integer that specifies the port number.
#   Defaults to the results of a PuppetDB query, or `[$trusted['certname']]`
#
# @param puppetdb_metrics
#   An Array of Hashes containing name/url pairs for each PuppetDB metric.
#   Refer to `functions/puppetdb_metrics.pp` for defaults.
#
# @example Configure Telegraf to collect metrics from a list of Primary Server, Compilers, PuppetDB, and PostgreSQL servers
#   class { 'puppet_metrics_dashboard':
#     add_dashboard_examples => true,
#     overwrite_dashboards   => false,
#     configure_telegraf     => true,
#     enable_telegraf        => true,
#     pe_server_list            => ['primary.example.com', ['compiler01.example.com', 9140], ['compiler02.example.com', 9140]],
#     puppetdb_list          => ['puppetdb01.example.com', 'puppetdb02.example.com'],
#     postgres_host_list     => ['postgres01.example.com', 'postgres02.example.com'],
#   }
#
# @example Configure Graphite to accept metrics from a list of Primary Server and Compilers
#   class { 'puppet_metrics_dashboard':
#     add_dashboard_examples => true,
#     overwrite_dashboards   => false,
#     consume_graphite       => true,
#     influxdb_database_name => ['graphite'],
#     pe_server_list            => ['primary', 'compiler01'],
#   }
#
# @example Configure Telegraf, Graphite, and Archive
#  class { 'puppet_metrics_dashboard':
#    add_dashboard_examples => true,
#    overwrite_dashboards   => false,
#    consume_graphite       => true,
#    configure_telegraf     => true,
#    enable_telegraf        => true,
#    influxdb_database_name => ['telegraf', 'graphite', 'puppet_metrics'],
#  }
#
class puppet_metrics_dashboard (
  Boolean $manage_repos,

  Boolean $add_dashboard_examples,
  Boolean $overwrite_dashboards,

  Boolean $enable_chronograf,
  Boolean $enable_kapacitor,
  Boolean $enable_telegraf,
  Boolean $configure_telegraf,
  Boolean $consume_graphite,

  Array[String] $influxdb_database_name,
  Array[String] $influxdb_urls,

  String $influx_db_service_name,
  String $influx_db_password,

  String $telegraf_db_name,
  String[2] $telegraf_agent_interval,
  String[2] $http_response_timeout,
  String[2] $pg_query_interval,

  Boolean $use_dashboard_ssl,
  Boolean $tidy_telegraf_configs,
  String $dashboard_cert_file,
  String $dashboard_cert_key,

  Boolean $enable_ldap_auth,

  Integer $grafana_http_port,
  String $grafana_password,
  String $grafana_version,

  String $overwrite_dashboards_file,

  Hash $grafana_config,

  Puppet_metrics_dashboard::HostList $pe_server_list        = puppet_metrics_dashboard::localhost_or_hosts_with_pe_profile('master'),
  Puppet_metrics_dashboard::HostList $puppetdb_list      = puppet_metrics_dashboard::localhost_or_hosts_with_pe_profile('puppetdb'),
  Puppet_metrics_dashboard::HostList $postgres_host_list = puppet_metrics_dashboard::localhost_or_hosts_with_pe_profile('database'),

  Puppet_metrics_dashboard::Puppetdb_metric $puppetdb_metrics = puppet_metrics_dashboard::puppetdb_metrics(),
  ) {

  unless $facts['os']['family'] =~ /^(RedHat|Debian)$/ {
    fail("Installation on ${facts['os']['family']} is not supported")
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

  # Always enable Telegraf if `configure_telegraf` is `true`.
  $_enable_telegraf = $configure_telegraf ? {
    true    => true,
    default => $enable_telegraf
  }

  if $_enable_telegraf {
    contain puppet_metrics_dashboard::telegraf
  }
}
