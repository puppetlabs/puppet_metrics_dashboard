class pe_metrics_dashboard::install(
  Boolean $add_dashboard_examples  =  $pe_metrics_dashboard::params::add_dashboard_examples,
  String $influx_db_service_name   =  $pe_metrics_dashboard::params::influx_db_service_name,
  String $influxdb_database_name   =  $pe_metrics_dashboard::params::influxdb_database_name,
  String $grafana_version          =  $pe_metrics_dashboard::params::grafana_version,
  Integer $grafana_http_port       =  $pe_metrics_dashboard::params::grafana_http_port,
  String $influx_db_password       =  $pe_metrics_dashboard::params::influx_db_password,
  String $grafana_password         =  $pe_metrics_dashboard::params::grafana_password
) inherits pe_metrics_dashboard::params {

  include pe_metrics_dashboard::repos

  package { 'influxdb':
    ensure  => present,
    require => Class['pe_metrics_dashboard::repos'],
  }

  service { $influx_db_service_name:
    ensure  => running,
    require => Package['influxdb'],
  }

  class { 'grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    version             => $grafana_version,
    cfg                 => {
      server   => {
        http_port      => $grafana_http_port,
      },
    },
    require             => Service[$influx_db_service_name],
  }

  ## install / enable kapacitor
  ->package { 'kapacitor':
    ensure  => present,
    require => Class['pe_metrics_dashboard::repos'],
  }

  ->service { 'kapacitor':
    ensure => running,
    enable => true,
  }
  -> package { 'telegraf':
    ensure  => present,
    require => Class['pe_metrics_dashboard::repos'],
  }

  ->service { 'telegraf':
    ensure => running,
    enable => true,
  }

  ## install / enable chronograf
  ->package { 'chronograf':
    ensure  => present,
    require => Class['pe_metrics_dashboard::repos'],
  }

  ->service { 'chronograf':
    ensure => running,
    enable => true,
  }

  # Fix a timing issue where influxdb does not start fully before creating users
  ->exec { 'wait for influxdb':
    command => '/bin/sleep 5',
    unless  => '/usr/bin/influx -execute "SHOW DATABASES"',
    require => Service['influxdb'],
  }

  ->exec { 'create influxdb admin user':
    command => "/usr/bin/influx -execute \"CREATE USER admin WITH PASSWORD '${influx_db_password}' WITH ALL PRIVILEGES\"",
    unless  => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \'show users\' | grep \'admin true\'",
    require => Exec['wait for influxdb'],
  }

  ->exec { 'create influxdb pe_metrics database':
    command => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \"create database ${influxdb_database_name}\"",
    unless  => "/usr/bin/influx -username admin -password ${influx_db_password} -execute \'show databases\' | grep ${$influxdb_database_name}",
  }

  # Configure grafana to use InfluxDB
  ->grafana_datasource { 'influxdb':
    grafana_url      => "http://localhost:${grafana_http_port}",
    type             => 'influxdb',
    database         => $influxdb_database_name,
    url              => 'http://localhost:8086',
    access_mode      => 'proxy',
    is_default       => true,
    user             => 'admin',
    password         => $influx_db_password,
    grafana_user     => 'admin',
    grafana_password => 'admin',
    require          => [Service['grafana-server'], Exec['create influxdb pe_metrics database']],
  }

  if $add_dashboard_examples {
    grafana_dashboard { 'PuppetDB Performance':
      grafana_url      => "http://localhost:${grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $grafana_password,
      content          => file('pe_metrics_dashboard/PuppetDB_Performance.json'),
      require          => Grafana_datasource['influxdb'],
    }

    grafana_dashboard { 'PuppetDB Workload':
      grafana_url      => "http://localhost:${grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $grafana_password,
      content          => file('pe_metrics_dashboard/PuppetDB_Workload.json'),
      require          => Grafana_datasource['influxdb'],
    }

    grafana_dashboard { 'Puppetserver Performance':
      grafana_url      => "http://localhost:${grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $grafana_password,
      content          => file('pe_metrics_dashboard/Puppetserver_Performance.json'),
      require          => Grafana_datasource['influxdb'],
    }
  }

}
