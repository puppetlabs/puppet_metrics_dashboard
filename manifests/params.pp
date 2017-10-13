# pe_metrics_dashboard::params
#
# A description of what this class does
#
# @summary Default parameters for the installation
#
# @example
class pe_metrics_dashboard::params {

  # Default Installation parameters
  $add_dashboard_examples =  false
  $influxdb_database_name =  'pe_metrics'
  $grafana_version        =  '4.5.2'
  $grafana_http_port      =  3000
  $influx_db_password     =  'puppet'
  $grafana_password       =  'admin'
  # Influxdb TICK stack
  $enable_telegraf        =  true
  $enable_kapacitor       =  false
  $enable_chronograf      =  false
  # telegraf config
  $configure_telegraf     =  false
  $master_list            =  []
  $puppetdb_list          =  []


  case $::osfamily {

    'RedHat': {
      $influx_db_service_name = 'influxdb'
    }
    'Debian': {
      $influx_db_service_name = 'influxd'
    }
    default: {
      fail("${::osfamily} installation not supported")
    }
  }

}
