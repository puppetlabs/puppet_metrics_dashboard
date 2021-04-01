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

  if puppet_metrics_dashboard::puppetdb_v2_metrics() {
    $pdb_dash_version = '_v2'
  } else {
    $pdb_dash_version = undef
  }

  ## This tests if the installation is PE or not.  We have a different dashboard for FOSS
  if is_function_available('pe_compiling_server_version') {
    $puppetserver_perf_template = 'Telegraf_Puppetserver_Performance.json'
  }
  else {
    $puppetserver_perf_template = 'Telegraf_FOSS_Puppetserver_Performance.json'
  }

  grafana_dashboard {
    default:
      grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $puppet_metrics_dashboard::grafana_password,
      require          => Grafana_datasource['influxdb_telegraf'],
    ;
    'Telegraf PuppetDB Performance':
      content => file("puppet_metrics_dashboard/Telegraf_PuppetDB_Performance${pdb_dash_version}.json"),
    ;
    'Telegraf PuppetDB Workload':
      content => file("puppet_metrics_dashboard/Telegraf_PuppetDB_Workload${pdb_dash_version}.json"),
    ;
    'Telegraf Puppetserver Performance':
      content => file("puppet_metrics_dashboard/${puppetserver_perf_template}"),
    ;
    'Telegraf Puppetserver Workload':
      content => file('puppet_metrics_dashboard/Telegraf_Puppetserver_Workload.json'),
    ;
    'Telegraf File Sync Metrics':
      content => file('puppet_metrics_dashboard/Telegraf_File_Sync.json'),
    ;
    'Telegraf Postgres Metrics':
      content => file('puppet_metrics_dashboard/Telegraf_Postgres.json'),
    ;
  }
}
