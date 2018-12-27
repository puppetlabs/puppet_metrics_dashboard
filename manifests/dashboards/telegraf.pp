# @summary Installs telegraf example dashboards
#
# Installs telegraf example dashboards
#
# @api private
class puppet_metrics_dashboard::dashboards::telegraf {
  $_uri = $puppet_metrics_dashboard::use_dashboard_ssl ? {
    true    => 'https',
    default => 'http',
  }

  grafana_dashboard {
    default:
      grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $puppet_metrics_dashboard::grafana_password,
      require          => Grafana_datasource['influxdb_telegraf'],
    ;
    'Telegraf PuppetDB Performance':
      content => file('puppet_metrics_dashboard/Telegraf_PuppetDB_Performance.json'),
    ;
    'Telegraf PuppetDB Workload':
      content => file('puppet_metrics_dashboard/Telegraf_PuppetDB_Workload.json'),
    ;
    'Telegraf Puppetserver Performance':
      content => file('puppet_metrics_dashboard/Telegraf_Puppetserver_Performance.json'),
    ;
    'Telegraf File Sync Metrics':
      content => file('puppet_metrics_dashboard/Telegraf_File_Sync.json'),
    ;
  }
}
