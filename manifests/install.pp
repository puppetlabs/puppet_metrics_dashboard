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
  }
}
