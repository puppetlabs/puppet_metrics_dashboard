# @summary Manages services
#
# Manages services
#
# @api private
class puppet_metrics_dashboard::service {
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

  service { $puppet_metrics_dashboard::influx_db_service_name:
    ensure  => running,
    enable  => true,
    require => Package['influxdb'],
  }

  if $puppet_metrics_dashboard::enable_chronograf {
    service { 'chronograf':
      ensure  => running,
      enable  => true,
      require => [
        Package['chronograf'],
        Service[$puppet_metrics_dashboard::influx_db_service_name]
      ],
    }
  }

  if $puppet_metrics_dashboard::enable_kapacitor {
    service { 'kapacitor':
      ensure  => running,
      enable  => true,
      require => [
        Package['kapacitor'],
        Service[$puppet_metrics_dashboard::influx_db_service_name]
      ],
    }
  }
}
