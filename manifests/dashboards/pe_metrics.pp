class pe_metrics_dashboard::dashboards::pe_metrics(  
  Integer $grafana_port  =  $pe_metrics_dashboard::params::grafana_http_port,
) inherits pe_metrics_dashboard::params {
   
  grafana_dashboard { 'Archive PuppetDB Performance':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/PuppetDB_Performance.json'),
    require          => Grafana_datasource['influxdb_pe_metrics'],
  }

  grafana_dashboard { 'Archive PuppetDB Workload':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/PuppetDB_Workload.json'),
    require          => Grafana_datasource['influxdb_pe_metrics'],
  }

  grafana_dashboard { 'Archive Puppetserver Performance':
    grafana_url      => "http://localhost:${grafana_port}",
    grafana_user     => 'admin',
    grafana_password => $grafana_password,
    content          => file('pe_metrics_dashboard/Puppetserver_Performance.json'),
    require          => Grafana_datasource['influxdb_pe_metrics'],
  }
}
