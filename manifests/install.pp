class pe_metrics_dashboard::install(
  $add_dashboard_examples =   false,
  $influxdb_database_name =   'pe_metrics',
  $grafana_version =          '4.5.2',
  $grafana_http_port =        '3000',
) {

  case $::osfamily {

    'RedHat': {  
       $influx_db_service_name = 'influxdb'
    }
    'Debian': {
      $influx_db_service_name = 'influxd'
    }
    default: {
      fail("$::osfamily installation not supported")
    }
  }

  class {'pe_metrics_dashboard::repos':}->

  package {'influxdb':
    ensure  => present,
  }->

  service {"${influx_db_service_name}":
    ensure  => running,
    require => Package['influxdb'],
  }->

  class { 'grafana':
    install_method => 'repo',
    manage_package_repo => false,
    version => $grafana_version,
    cfg => {
      server   => {
        http_port      => $grafana_http_port,
      },
    },
  }->

  ## install / enable kapacitor
  package {'kapacitor':
    ensure => present,
    require => Class['pe_metrics_dashboard::repos'],
  }->

  service {'kapacitor':
    ensure  => running,
    enable  => true,
  }->

  ## install / enable telegraf
  package {'telegraf':
    ensure => present,
    require => Class['pe_metrics_dashboard::repos'],
  }->

  service {'telegraf':
    ensure  => running,
    enable  => true,
  }->

  ## install / enable chronograf
  package {'chronograf':
    ensure => present,
    require => Class['pe_metrics_dashboard::repos'],
  }->

  service {'chronograf':
    ensure => running,
    enable => true,
  }->

  exec {'create influxdb admin user':
    command => '/usr/bin/influx -execute "CREATE USER admin WITH PASSWORD \'puppet\' WITH ALL PRIVILEGES"',
    unless => '/usr/bin/influx -username admin -password puppet -execute \'show users\' | grep \'admin true\''
  }->

  exec {'create influxdb pe_metrics database':
    command => "/usr/bin/influx -username admin -password puppet -execute \"create database ${influxdb_database_name}\"",
    unless => "/usr/bin/influx -username admin -password puppet -execute \'show databases\' | grep ${$influxdb_database_name}"
  }->

  # Configure grafana to use InfluxDB
  grafana_datasource { "influxdb":
    grafana_url      => "http://localhost:${grafana_http_port}",
    type             => 'influxdb',
    database         => $influxdb_database_name,
    url              => 'http://localhost:8086',
    access_mode      => 'proxy',
    is_default       => true,
    user             => 'admin',
    password         => 'puppet',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    require          => Service['grafana-server'],
  }

  if $add_dashboard_examples {
    grafana_dashboard { 'PuppetDB Performance':
      grafana_url       => "http://localhost:${grafana_http_port}",
      grafana_user      => 'admin',
      grafana_password  => 'admin',
      content           => file('pe_metrics_dashboard/PuppetDB_Performance.json'),
    }

    grafana_dashboard { 'PuppetDB Workload':
      grafana_url       => "http://localhost:${grafana_http_port}",
      grafana_user      => 'admin',
      grafana_password  => 'admin',
      content           => file('pe_metrics_dashboard/PuppetDB_Workload.json'),
    }
 
    grafana_dashboard { 'Puppetserver Performance':
      grafana_url       => "http://localhost:${grafana_http_port}",
      grafana_user      => 'admin',
      grafana_password  => 'admin',
      content           => file('pe_metrics_dashboard/Puppetserver_Performance.json'),
    }
  }

}
