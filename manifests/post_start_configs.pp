# @summary InfluxDB post-start configs
#
# Some InfluxDB configuration requires the InfluxDB service to first be running.
# Configs that fall into that category are contained here.
#
# @api private
class puppet_metrics_dashboard::post_start_configs {
  $influx_command = $facts['os']['family'] ? {
    'Suse' => '/opt/influxdb/usr/bin/influx',
    default => '/usr/bin/influx'
  }
  # Fix a timing issue where influxdb does not start fully before creating users
  exec { 'wait for influxdb':
    command => '/bin/sleep 10',
    unless  => "${influx_command} -execute \"SHOW DATABASES\"",
    require => Service[$puppet_metrics_dashboard::influx_db_service_name],
  }

  # lint:ignore:140chars
  exec { 'create influxdb admin user':
    command => "${influx_command} -execute \"CREATE USER admin WITH PASSWORD '${puppet_metrics_dashboard::influx_db_password}' WITH ALL PRIVILEGES\"",
    unless  => "${influx_command} -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \'show users\' | grep \'admin true\'",
    require => Exec['wait for influxdb'],
  }
  # lint:endignore

  $puppet_metrics_dashboard::influxdb_database_name.each |$db_name| {
    # lint:ignore:140chars
    exec { "create influxdb puppet_metrics database ${db_name}":
      command => "${influx_command} -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"create database ${db_name}\"",
      unless  => "${influx_command} -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \'show databases\' | grep ${db_name}",
      require => Exec['create influxdb admin user'],
    }
    # lint:endignore
  }

  $_uri = $puppet_metrics_dashboard::use_dashboard_ssl ? {
    true    => 'https',
    default => 'http',
  }

  # Configure grafana to use InfluxDB with any number of database names
  $puppet_metrics_dashboard::influxdb_database_name.each |$db_name| {
    grafana_datasource { "influxdb_${db_name}":
      grafana_url      => "${_uri}://localhost:${puppet_metrics_dashboard::grafana_http_port}",
      type             => 'influxdb',
      database         => $db_name,
      url              => 'http://localhost:8086',
      access_mode      => 'proxy',
      is_default       => false,
      user             => 'admin',
      password         => $puppet_metrics_dashboard::influx_db_password,
      grafana_user     => 'admin',
      grafana_password => $puppet_metrics_dashboard::grafana_password,
      require          => [
        Service['grafana-server'],
        Exec["create influxdb puppet_metrics database ${db_name}"]
      ],
    }
  }
}
