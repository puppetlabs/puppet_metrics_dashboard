# @summary Installs puppet_metrics example dashboards
#
# Installs puppet_metrics example dashboards
#
# @api private
class puppet_metrics_dashboard::dashboards::puppet_metrics {
  $_uri = $puppet_metrics_dashboard::use_dashboard_ssl ? {
    true    => 'https',
    default => 'http',
  }

  grafana_dashboard {
    default:
      grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $puppet_metrics_dashboard::grafana_password,
      require          => Grafana_datasource['influxdb_puppet_metrics'],
    ;
    'Archive PuppetDB Performance':
      content => file('puppet_metrics_dashboard/PuppetDB_Performance.json'),
    ;
    'Archive PuppetDB Workload':
      content => file('puppet_metrics_dashboard/PuppetDB_Workload.json'),
    ;
    'Archive Puppetserver Performance':
      content => file('puppet_metrics_dashboard/Puppetserver_Performance.json'),
    ;
    'Archive File Sync Metrics':
      content => file('puppet_metrics_dashboard/Archive_File_Sync.json'),
    ;
  }
}
