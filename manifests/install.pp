class pe_metrics_dashboard::install(
  Boolean $add_dashboard_examples         =  $pe_metrics_dashboard::params::add_dashboard_examples,
  String $influx_db_service_name          =  $pe_metrics_dashboard::params::influx_db_service_name,
  Array[String] $influxdb_database_name   =  $pe_metrics_dashboard::params::influxdb_database_name,
  String $grafana_version                 =  $pe_metrics_dashboard::params::grafana_version,
  Integer $grafana_http_port              =  $pe_metrics_dashboard::params::grafana_http_port,
  String $influx_db_password              =  $pe_metrics_dashboard::params::influx_db_password,
  String $grafana_password                =  $pe_metrics_dashboard::params::grafana_password,
  Boolean $enable_kapacitor               =  $pe_metrics_dashboard::params::enable_kapacitor,
  Boolean $enable_chronograf              =  $pe_metrics_dashboard::params::enable_chronograf,
  Boolean $enable_telegraf                =  $pe_metrics_dashboard::params::enable_telegraf,
  Boolean $configure_telegraf             =  $pe_metrics_dashboard::params::configure_telegraf,
  Boolean $consume_graphite               =  $pe_metrics_dashboard::params::consume_graphite,
  Array[String] $master_list              =  $pe_metrics_dashboard::params::master_list,
  Array[String] $puppetdb_list            =  $pe_metrics_dashboard::params::puppetdb_list
) inherits pe_metrics_dashboard::params {

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
    }
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
    cfg                 => {
      server   => {
        http_port      => $grafana_http_port,
      },
    },
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
    package { 'telegraf':
      ensure  => present,
      require => Class['pe_metrics_dashboard::repos'],
    }

    if $configure_telegraf {

      file {'/etc/telegraf/telegraf.conf':
        ensure  => file,
        owner   => 0,
        group   => 0,
        content => epp('pe_metrics_dashboard/telegraf.conf.epp'),
        notify  => Service['telegraf'],
      }
    }

    service { 'telegraf':
      ensure  => running,
      enable  => true,
      require => [Package['telegraf'], Service[$influx_db_service_name]],
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
      grafana_url      => "http://localhost:${grafana_http_port}",
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

  if ($add_dashboard_examples) and ('pe_metrics' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::pe_metrics':
      grafana_port => $grafana_http_port,
    }
  }

  if ($add_dashboard_examples) and ('telegraf' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::telegraf':
      grafana_port => $grafana_http_port,
    }
  }

  if ($add_dashboard_examples) and ('graphite' in $influxdb_database_name){
    class {'pe_metrics_dashboard::dashboards::graphite':
      grafana_port => $grafana_http_port,
    }
  }

}
