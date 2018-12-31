# @summary Configures Grafana dashboards.
#
# Configures Grafana dashboards.
#
# @api private
class puppet_metrics_dashboard::dashboards {
  if $puppet_metrics_dashboard::add_dashboard_examples {
    $_overwrite_dashboards_ensure = $puppet_metrics_dashboard::overwrite_dashboards ? {
      true  =>  'absent',
      false => 'file',
    }

    file { $puppet_metrics_dashboard::overwrite_dashboards_file:
      ensure => $_overwrite_dashboards_ensure,
      mode   => '0644',
    }

    $_overwrite = $facts['overwrite_dashboards_disabled'] ? {
      true    => false,
      default => true,
    }
    $_dblist = $puppet_metrics_dashboard::influxdb_database_name

    if $_overwrite and ('graphite' in $_dblist){
      include puppet_metrics_dashboard::dashboards::graphite
    }

    if $_overwrite and ('puppet_metrics' in $_dblist){
      include puppet_metrics_dashboard::dashboards::puppet_metrics
    }

    if $_overwrite and ('telegraf' in $_dblist){
      include puppet_metrics_dashboard::dashboards::telegraf
    }
  }
}
