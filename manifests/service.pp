# @summary Manages services
#
# Manages services
#
# @api private
class puppet_metrics_dashboard::service {
  case $facts['os']['family'] {
    'Suse': {
      systemd::unit_file { "${puppet_metrics_dashboard::influx_db_service_name}.service":
        source => "puppet:///modules/${module_name}/influxdb.service",
        enable => true,
        active => true,
      }
    }
    default: {
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
  }
}
