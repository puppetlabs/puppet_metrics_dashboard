# Class: pe_metrics_dashboard
# ===========================
#
# Full description of class pe_metrics_dashboard here.
#
# Parameters
# ----------
#
# Document parameters here.
#
# * `sample parameter`
# Explanation of what this parameter affects and what it defaults to.
# e.g. "Specify one or more upstream ntp servers as an array."
#
# Variables
# ----------
#
# Here you should define a list of variables that this module would require.
#
# * `sample variable`
#  Explanation of how this variable affects the function of this class and if
#  it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#  External Node Classifier as a comma separated list of hostnames." (Note,
#  global variables should be avoided in favor of class parameters as
#  of Puppet 2.6.)
#
# Examples
# --------
#
# @example
#    class { 'pe_metrics_dashboard':
#      servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#    }
#
# Authors
# -------
#
# Author Name <author@domain.com>
#
# Copyright
# ---------
#
# Copyright 2017 Your name here, unless otherwise noted.
#
class pe_metrics_dashboard (
  Boolean $add_dashboard_examples         =  $pe_metrics_dashboard::params::add_dashboard_examples,
  Boolean $use_dashboard_ssl              =  $pe_metrics_dashboard::params::use_dashboard_ssl,
  String $dashboard_cert_file             =  $pe_metrics_dashboard::params::dashboard_cert_file,
  String $dashboard_cert_key              =  $pe_metrics_dashboard::params::dashboard_cert_key,
  Boolean $overwrite_dashboards           =  $pe_metrics_dashboard::params::overwrite_dashboards,
  String $overwrite_dashboards_file       =  $pe_metrics_dashboard::params::overwrite_dashboards_file,
  String $influx_db_service_name          =  $pe_metrics_dashboard::params::influx_db_service_name,
  Array[String] $influxdb_database_name   =  $pe_metrics_dashboard::params::influxdb_database_name,
  String $grafana_version                 =  $pe_metrics_dashboard::params::grafana_version,
  Integer $grafana_http_port              =  $pe_metrics_dashboard::params::grafana_http_port,
  String $influx_db_password              =  $pe_metrics_dashboard::params::influx_db_password,
  String $grafana_password                =  $pe_metrics_dashboard::params::grafana_password,
  Boolean $enable_kapacitor               =  $pe_metrics_dashboard::params::enable_kapacitor,
  Boolean $enable_chronograf              =  $pe_metrics_dashboard::params::enable_chronograf,
  Boolean $enable_telegraf                =  $pe_metrics_dashboard::params::enable_telegraf,
  Boolean $configure_telegraf             =  $pe_metrics_dashboard::params::configure_telegraf,
  Boolean $consume_graphite               =  $pe_metrics_dashboard::params::consume_graphite,
  Array[String] $master_list              =  $pe_metrics_dashboard::params::master_list,
  Array[String] $puppetdb_list            =  $pe_metrics_dashboard::params::puppetdb_list
) inherits pe_metrics_dashboard::params {

  class { 'pe_metrics_dashboard::install':
    add_dashboard_examples    =>  $add_dashboard_examples,
    use_dashboard_ssl         =>  $use_dashboard_ssl,
    dashboard_cert_file       =>  $dashboard_cert_file,
    dashboard_cert_key        =>  $dashboard_cert_key,
    overwrite_dashboards      =>  $overwrite_dashboards,
    overwrite_dashboards_file =>  $overwrite_dashboards_file,
    influx_db_service_name    =>  $influx_db_service_name,
    influxdb_database_name    =>  $influxdb_database_name,
    grafana_version           =>  $grafana_version,
    grafana_http_port         =>  $grafana_http_port,
    influx_db_password        =>  $influx_db_password,
    grafana_password          =>  $grafana_password,
    enable_kapacitor          =>  $enable_kapacitor,
    enable_chronograf         =>  $enable_chronograf,
    enable_telegraf           =>  $enable_telegraf,
    configure_telegraf        =>  $configure_telegraf,
    consume_graphite          =>  $consume_graphite,
    master_list               =>  $master_list,
    puppetdb_list             =>  $puppetdb_list,
  }
}
