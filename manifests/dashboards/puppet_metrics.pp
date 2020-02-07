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

  grafana_folder { 'Deeper Dives':
    ensure           => present,
    grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
    grafana_user     => 'admin',
    grafana_password => $puppet_metrics_dashboard::grafana_password,
  }

  grafana_dashboard {
    default:
      grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
      grafana_user     => 'admin',
      grafana_password => $puppet_metrics_dashboard::grafana_password,
      require          => [
        Grafana_datasource['influxdb_puppet_metrics'],
        Grafana_folder['Deeper Dives'],
      ],
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
    'Archive Orchestration Services':
      content => file('puppet_metrics_dashboard/Orchestration_Services.json'),
    ;
    'Archive Process/System Stats':
      content => file('puppet_metrics_dashboard/Process_System_Stats.json'),
    ;
    'Archive File Sync Metrics':
      content => file('puppet_metrics_dashboard/Archive_File_Sync.json'),
    ;
    'Archive Ace Puma Performance':
      content => file('puppet_metrics_dashboard/Ace_Puma_Performance.json'),
      folder  => 'Deeper Dives',
    ;
    'Archive Bolt Puma Performance':
      content => file('puppet_metrics_dashboard/Bolt_Puma_Performance.json'),
      folder  => 'Deeper Dives',
    ;
    'Archive Orchestrator JVM Performance':
      content => file('puppet_metrics_dashboard/Orchestrator_JVM_Performance.json'),
      folder  => 'Deeper Dives',
    ;
    'Archive PuppetDB JVM Performance':
      content => file('puppet_metrics_dashboard/PuppetDB_JVM_Performance.json'),
      folder  => 'Deeper Dives',
    ;
    'Archive Puppetserver JVM Performance':
      content => file('puppet_metrics_dashboard/Puppetserver_JVM_Performance.json'),
      folder  => 'Deeper Dives',
    ;
  }
}
