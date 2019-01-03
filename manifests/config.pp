# @summary Configures dashboard components.
#
# Configures dashboard components
#
# @api private
class puppet_metrics_dashboard::config {
  if $puppet_metrics_dashboard::consume_graphite {
    file {'/etc/influxdb/influxdb.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      content => epp('puppet_metrics_dashboard/influxdb.conf.epp', {
        master_list => $puppet_metrics_dashboard::master_list,
      }),
      notify  => Service[$puppet_metrics_dashboard::influx_db_service_name],
      require => Package['influxdb'],
    }
  }
}
