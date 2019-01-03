# @summary Installs graphite example dashboards
#
# Installs graphite example dashboards
#
# @api private
class puppet_metrics_dashboard::dashboards::graphite {
  $_uri = $puppet_metrics_dashboard::use_dashboard_ssl ? {
    true    => 'https',
    default => 'http',
  }

  grafana_dashboard { 'Graphite Puppetserver Performance':
    grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
    grafana_user     => 'admin',
    grafana_password => $puppet_metrics_dashboard::grafana_password,
    content          => file('puppet_metrics_dashboard/Graphite_Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_graphite'],
  }
}
