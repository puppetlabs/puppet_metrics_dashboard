# Class: pe_metrics_dashboard::dashboards::telegraf
# ===========================
#
# Installs telegraf example dashboards
#
class pe_metrics_dashboard::dashboards::telegraf(
  Integer $grafana_port       =  $pe_metrics_dashboard::install::grafana_http_port,
  String $grafana_password    =  $pe_metrics_dashboard::install::grafana_password,
  Boolean $use_dashboard_ssl  =  $pe_metrics_dashboard::install::use_dashboard_ssl,
) {

  if $use_dashboard_ssl {
    $uri = 'https'
  }
  else {
    $uri = 'http'
  }

  grafana_dashboard { 'Telegraf PuppetDB Performance':
    grafana_url      => "${uri}://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_PuppetDB_Performance.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }

  grafana_dashboard { 'Telegraf PuppetDB Workload':
    grafana_url      => "${uri}://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_PuppetDB_Workload.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }

  grafana_dashboard { 'Telegraf Puppetserver Performance':
    grafana_url      => "${uri}://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }

  grafana_dashboard { 'Telegraf File Sync Metrics':
    grafana_url      => "${uri}://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Telegraf_File_Sync.json'),
    require          => Grafana_datasource['influxdb_telegraf'],
  }
}
