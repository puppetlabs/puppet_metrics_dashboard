class pe_metrics_dashboard::dashboards::telegraf(
  Integer $grafana_port              =  $pe_metrics_dashboard::params::grafana_http_port,
) inherits pe_metrics_dashboard::params {

  grafana_dashboard { 'Telegraf PuppetDB Performance':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_PuppetDB_Performance.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }

  grafana_dashboard { 'Telegraf Puppetserver Performance':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }
}
