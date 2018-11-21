# @summary Installs and configures Grafana and InfluxDB components.
# @api private
class puppet_metrics_dashboard::install(
  Boolean $add_dashboard_examples         =  $puppet_metrics_dashboard::params::add_dashboard_examples,
  Boolean $manage_repos                   =  $puppet_metrics_dashboard::params::manage_repos,
  Boolean $use_dashboard_ssl              =  $puppet_metrics_dashboard::params::use_dashboard_ssl,
  String $dashboard_cert_file             =  $puppet_metrics_dashboard::params::dashboard_cert_file,
  String $dashboard_cert_key              =  $puppet_metrics_dashboard::params::dashboard_cert_key,
  Boolean $overwrite_dashboards           =  $puppet_metrics_dashboard::params::overwrite_dashboards,
  String $overwrite_dashboards_file       =  $puppet_metrics_dashboard::params::overwrite_dashboards_file,
  String $influx_db_service_name          =  $puppet_metrics_dashboard::params::influx_db_service_name,
  Array[String] $influxdb_database_name   =  $puppet_metrics_dashboard::params::influxdb_database_name,
  String $grafana_version                 =  $puppet_metrics_dashboard::params::grafana_version,
  Integer $grafana_http_port              =  $puppet_metrics_dashboard::params::grafana_http_port,
  String $influx_db_password              =  $puppet_metrics_dashboard::params::influx_db_password,
  String $grafana_password                =  $puppet_metrics_dashboard::params::grafana_password,
  Boolean $enable_kapacitor               =  $puppet_metrics_dashboard::params::enable_kapacitor,
  Boolean $enable_chronograf              =  $puppet_metrics_dashboard::params::enable_chronograf,
  Boolean $enable_telegraf                =  $puppet_metrics_dashboard::params::enable_telegraf,
  Boolean $configure_telegraf             =  $puppet_metrics_dashboard::params::configure_telegraf,
  Boolean $consume_graphite               =  $puppet_metrics_dashboard::params::consume_graphite,
  Array[String] $master_list              =  $puppet_metrics_dashboard::params::master_list,
  Array[String] $puppetdb_list            =  $puppet_metrics_dashboard::params::puppetdb_list,
  String $postgres_host                   =  $puppet_metrics_dashboard::params::postgres_host,
) inherits puppet_metrics_dashboard::params {

  # Enable Telegraf if `configure_telegraf` is true.
  $_enable_telegraf = $configure_telegraf ? {
    true    => true,
    default => $enable_telegraf
  }

  class { 'puppet_metrics_dashboard::repos':
    manage_repos => $manage_repos,
  }

  package { 'influxdb':
    ensure  => present,
    require => Class['puppet_metrics_dashboard::repos'],
  }

  if $consume_graphite {

    file {'/etc/influxdb/influxdb.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      content => epp('puppet_metrics_dashboard/influxdb.conf.epp',
        {master_list => $master_list}),
      notify  => Service[$influx_db_service_name],
      require => Package['influxdb'],
    }
  }

  # certificates are only needed to enable SSL on the grafana dashboard and for connecting to a postgres instance, but we create them regardless
  include puppet_metrics_dashboard::certs

  if $use_dashboard_ssl {
    $cfg = { server    => {
              http_port => $grafana_http_port,
              protocol  => 'https',
              cert_file => $dashboard_cert_file,
              cert_key  => $dashboard_cert_key,
            },
    }
    $uri = 'https'
  }
  else {
    $cfg = { server    => {
              http_port => $grafana_http_port,
              },
    }
    $uri = 'http'
  }

  service { $influx_db_service_name:
    ensure  => running,
    require => Package['influxdb'],
  }

  if $facts['os']['family'] == 'RedHat' and $facts['os']['release']['major'] == '7' {

    file { '/usr/lib/tmpfiles.d/grafana.conf' :
      ensure  => file,
      content => 'd /var/run/grafana 0755 grafana grafana',
      require => Package['grafana'],
      before  => Service['grafana-server'],
      notify  => Exec['Create Systemd Temp Files'],
    }
    exec { 'Create Systemd Temp Files':
      command     => '/bin/systemd-tmpfiles --create',
      refreshonly => true,
    }
  }

  class { 'grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    version             => $grafana_version,
    cfg                 => $cfg,
    require             => Service[$influx_db_service_name],
  }

  if $enable_kapacitor {
    package { 'kapacitor':
      ensure  => present,
      require => Class['puppet_metrics_dashboard::repos'],
    }

    service { 'kapacitor':
      ensure  => running,
      enable  => true,
      require => [Package['kapacitor'], Service[$influx_db_service_name]],
    }
  }

  if $_enable_telegraf {
    class { 'puppet_metrics_dashboard::telegraf':
      configure_telegraf     => $configure_telegraf,
      influx_db_service_name => $influx_db_service_name,
      master_list            => $master_list,
      puppetdb_list          => $puppetdb_list,
      postgres_host          => $postgres_host,
    }
  }

  if $enable_chronograf {
    package { 'chronograf':
      ensure  => present,
      require => Class['puppet_metrics_dashboard::repos'],
    }

    service { 'chronograf':
      ensure  => running,
      enable  => true,
      require => [Package['chronograf'], Service[$influx_db_service_name]],
    }
  }

  # Fix a timing issue where influxdb does not start fully before creating users
  exec { 'wait for influxdb':
    command => '/bin/sleep 10',
    unless  => '/usr/bin/influx -execute "SHOW DATABASES"',
    require => Service[$influx_db_service_name],
  }

  exec { 'create influxdb admin user':
    command => "/usr/bin/influx -execute \"CREATE USER admin WITH PASSWORD '${influx_db_password}' WITH ALL PRIVILEGES\"",
    unless  => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \'show users\' | grep \'admin true\'",
    require => Exec['wait for influxdb'],
  }

  $influxdb_database_name.each |$db_name| {
    exec { "create influxdb puppet_metrics database ${db_name}":
      command => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \"create database ${db_name}\"",
      unless  => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \'show databases\' | grep ${db_name}",
      require => Exec['create influxdb admin user'],
    }
  }

  # Configure grafana to use InfluxDB with any number of database names
  $influxdb_database_name.each |$db_name| {
    grafana_datasource { "influxdb_${db_name}":
      grafana_url      => "${uri}://localhost:${grafana_http_port}",
      type             => 'influxdb',
      database         => $db_name,
      url              => 'http://localhost:8086',
      access_mode      => 'proxy',
      is_default       => false,
      user             => 'admin',
      password         => $influx_db_password,
      grafana_user     => 'admin',
      grafana_password => 'admin',
      require          => [Service['grafana-server'], Exec["create influxdb puppet_metrics database ${db_name}"]],
    }
  }


  $overwrite_dashboards_ensure = $overwrite_dashboards ? {
    true  =>  'absent',
    false => 'file',
  }
  file { $overwrite_dashboards_file:
    ensure => $overwrite_dashboards_ensure,
    mode   => '0644',
  }

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('puppet_metrics' in $influxdb_database_name){
    class {'puppet_metrics_dashboard::dashboards::puppet_metrics':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('telegraf' in $influxdb_database_name){
    class {'puppet_metrics_dashboard::dashboards::telegraf':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('graphite' in $influxdb_database_name){
    class {'puppet_metrics_dashboard::dashboards::graphite':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

}
