class pe_metrics_dashboard::dashboards::graphite(
  Integer $grafana_port     =  $pe_metrics_dashboard::params::grafana_http_port,
  String $grafana_password  =  $pe_metrics_dashboard::params::grafana_password,
) inherits pe_metrics_dashboard::params {

  grafana_dashboard { 'Graphite Puppetserver Performance':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Graphite_Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_graphite'],
  }
}
