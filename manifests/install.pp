class pe_metrics_dashboard::install {

  yumrepo {'influxdb':
    ensure   => present,
    enabled  => 1,
    gpgcheck => 1,
    baseurl  => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
    gpgkey   => 'https://repos.influxdata.com/influxdb.key',
  }

  package {'influxdb':
    ensure  => present,
    require => Yumrepo['influxdb'],
  }

  service {'influxdb':
    ensure  => running,
    require => Package['influxdb'],
  }->

  exec {'create influxdb admin user':
    command => '/usr/bin/influx -execute "CREATE USER admin WITH PASSWORD \'puppet\' WITH ALL PRIVILEGES"',
    unless => '/usr/bin/influx -username admin -password puppet -execute \'show users\' | grep \'admin true\''
  }->

  exec {'create influxdb pe_metrics database':
    command => '/usr/bin/influx -username admin -password puppet -execute "create database pe_metrics"',
    unless => '/usr/bin/influx -username admin -password puppet -execute \'show databases\' | grep pe_metrics'
  }

  yumrepo { 'grafana-repo':
    ensure        => 'present',
    baseurl       => 'https://packagecloud.io/grafana/stable/el/6/$basearch',
    descr         => 'grafana-repository',
    enabled       => '1',
    repo_gpgcheck => '1',
    gpgcheck      => '1',
    gpgkey        => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
    sslverify     => '1',
    sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
  }->

  class { 'grafana':
    install_method => 'repo',
    manage_package_repo => false,
    version => '4.4.3',
  }

  # Configure grafana to use InfluxDB
  grafana_datasource { 'influxdb':
    grafana_url      => 'http://localhost:3000',
    type             => 'influxdb',
    database         => 'pe_metrics',
    url              => 'http://localhost:8086',
    access_mode      => 'proxy',
    is_default       => true,
    user             => 'admin',
    password         => 'puppet',
    grafana_user     => 'admin',
    grafana_password => 'admin',
    require          => Service['grafana-server'],
  }

  grafana_dashboard { 'PuppetDB Performance':
    grafana_url       => 'http://localhost:3000',
    grafana_user      => 'admin',
    grafana_password  => 'admin',
    content           => file('pe_metrics_dashboard/PuppetDB_Performance.json'),
  }

  grafana_dashboard { 'PuppetDB Workload':
    grafana_url       => 'http://localhost:3000',
    grafana_user      => 'admin',
    grafana_password  => 'admin',
    content           => file('pe_metrics_dashboard/PuppetDB_Workload.json'),
  }
 
  grafana_dashboard { 'Puppetserver Performance':
    grafana_url       => 'http://localhost:3000',
    grafana_user      => 'admin',
    grafana_password  => 'admin',
    content           => file('pe_metrics_dashboard/Puppetserver_Performance.json'),
  }

  ## install / enable kapacitor
  package {'kapacitor':
    ensure => present,
  }->

  service {'kapacitor':
    ensure  => running,
    enable  => true,
  }

  ## install / enable telegraf
  package {'telegraf':
    ensure => present,
  }->  

  service {'telegraf':
    ensure  => running,
    enable  => true,
  }

  ## install / enable chronograf

  package {'chronograf':
    ensure => present,
  }->

  service {'chronograf':
    ensure => running,
    enable => true,
  }

}
