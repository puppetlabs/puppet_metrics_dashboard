# @summary Installs and configures Grafana and INfluxDB components.
class pe_metrics_dashboard::install(
  Boolean $add_dashboard_examples         =  $pe_metrics_dashboard::add_dashboard_examples,
  Boolean $use_dashboard_ssl              =  $pe_metrics_dashboard::use_dashboard_ssl,
  String $dashboard_cert_file             =  $pe_metrics_dashboard::dashboard_cert_file,
  String $dashboard_cert_key              =  $pe_metrics_dashboard::dashboard_cert_key,
  Boolean $overwrite_dashboards           =  $pe_metrics_dashboard::overwrite_dashboards,
  String $overwrite_dashboards_file       =  $pe_metrics_dashboard::overwrite_dashboards_file,
  String $influx_db_service_name          =  $pe_metrics_dashboard::influx_db_service_name,
  Array[String] $influxdb_database_name   =  $pe_metrics_dashboard::influxdb_database_name,
  String $grafana_version                 =  $pe_metrics_dashboard::grafana_version,
  Integer $grafana_http_port              =  $pe_metrics_dashboard::grafana_http_port,
  String $influx_db_password              =  $pe_metrics_dashboard::influx_db_password,
  String $grafana_password                =  $pe_metrics_dashboard::grafana_password,
  Boolean $enable_kapacitor               =  $pe_metrics_dashboard::enable_kapacitor,
  Boolean $enable_chronograf              =  $pe_metrics_dashboard::enable_chronograf,
  Boolean $enable_telegraf                =  $pe_metrics_dashboard::enable_telegraf,
  Boolean $configure_telegraf             =  $pe_metrics_dashboard::configure_telegraf,
  Boolean $consume_graphite               =  $pe_metrics_dashboard::consume_graphite,
  Array[String] $master_list              =  $pe_metrics_dashboard::master_list,
  Array[String] $puppetdb_list            =  $pe_metrics_dashboard::puppetdb_list
) {

  include pe_metrics_dashboard::repos

  package { 'influxdb':
    ensure  => present,
    require => Class['pe_metrics_dashboard::repos'],
  }

  if $consume_graphite {

    file {'/etc/influxdb/influxdb.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      content => file('pe_metrics_dashboard/influxdb.conf'),
      notify  => Service[$influx_db_service_name],
      require => Package['influxdb'],
    }
  }

  if $use_dashboard_ssl {
    $cfg = { server    => {
              http_port => $grafana_http_port,
              protocol  => 'https',
              cert_file => $dashboard_cert_file,
              cert_key  => $dashboard_cert_key,
            },
    }

    file { $dashboard_cert_file:
      ensure  => present,
      source  => "${facts['puppet_sslpaths']['certdir']['path']}/${clientcert}.pem",
      owner   => 'grafana',
      mode    => '0400',
      require => Package['grafana'],
    }

    file { $dashboard_cert_key:
      ensure  => present,
      source  => "${facts['puppet_sslpaths']['privatekeydir']['path']}/${clientcert}.pem",
      owner   => 'grafana',
      mode    => '0400',
      require => Package['grafana'],
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

  # Hacky workaround for #12
  if $facts['os']['family'] == 'RedHat' and !defined(File['/var/run/grafana']) {

    file { '/var/run/grafana' :
      ensure  => directory,
      owner   => 'grafana',
      group   => 'grafana',
      require => Package['grafana'],
      before  => Service['grafana-server'],
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
      require => Class['pe_metrics_dashboard::repos'],
    }

    service { 'kapacitor':
      ensure  => running,
      enable  => true,
      require => [Package['kapacitor'], Service[$influx_db_service_name]],
    }
  }

  if $enable_telegraf {
    class { 'pe_metrics_dashboard::telegraf':
      configure_telegraf     => $configure_telegraf,
      influx_db_service_name => $influx_db_service_name,
    }
  }

  if $enable_chronograf {
    package { 'chronograf':
      ensure  => present,
      require => Class['pe_metrics_dashboard::repos'],
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
    exec { "create influxdb pe_metrics database ${db_name}":
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
      require          => [Service['grafana-server'], Exec["create influxdb pe_metrics database ${db_name}"]],
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

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('pe_metrics' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::pe_metrics':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('telegraf' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::telegraf':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

  if ($add_dashboard_examples) and ! $facts['overwrite_dashboards_disabled'] and ('graphite' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::graphite':
      grafana_port      => $grafana_http_port,
      use_dashboard_ssl => $use_dashboard_ssl,
    }
  }

}
