# @summary Installs graphite example dashboards
#
# @api private
class puppet_metrics_dashboard::dashboards::graphite(
  Integer $grafana_port       =  $puppet_metrics_dashboard::install::grafana_http_port,
  String $grafana_password    =  $puppet_metrics_dashboard::install::grafana_password,
  Boolean $use_dashboard_ssl  =  $puppet_metrics_dashboard::install::use_dashboard_ssl,
) {

  if $use_dashboard_ssl {
    $uri = 'https'
  }
  else {
    $uri = 'http'
  }

  grafana_dashboard { 'Graphite Puppetserver Performance':
    grafana_url      => "${uri}://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('puppet_metrics_dashboard/Graphite_Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_graphite'],
  }
}
