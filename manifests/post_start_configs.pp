# @summary InfluxDB post-start configs
#
# Some InfluxDB configuration requires the InfluxDB service to first be running.
# Configs that fall into that category are contained here.
#
# @api private
class puppet_metrics_dashboard::post_start_configs {
  Exec {
    path => ['/usr/bin', '/opt/influxdb/usr/bin', '/usr/local/bin', '/bin']
  }
  # Fix a timing issue where influxdb does not start fully before creating users
  exec { 'wait for influxdb':
    command => '/bin/sleep 10',
    unless  => "influx -execute \"SHOW DATABASES\"",
    require => Service[$puppet_metrics_dashboard::influx_db_service_name],
  }

  # lint:ignore:140chars
  exec { 'create influxdb admin user':
    command => "influx -execute \"CREATE USER admin WITH PASSWORD '${puppet_metrics_dashboard::influx_db_password}' WITH ALL PRIVILEGES\"",
    unless  => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \'show users\' | grep \'admin true\'",
    require => Exec['wait for influxdb'],
  }
  # lint:endignore

  $puppet_metrics_dashboard::influxdb_database_name.each |$db_name| {
    # lint:ignore:140chars
    exec { "create influxdb puppet_metrics database ${db_name}":
      command => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"create database ${db_name}\"",
      unless  => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \'show databases\' | grep ${db_name}",
      require => Exec['create influxdb admin user'],
    }
    # lint:endignore
  }

  if $puppet_metrics_dashboard::telegraf_db_retention_duration =~ NotUndef {
    exec { "create default telegraf database retention policy":
      command => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"CREATE RETENTION POLICY telegraf_default ON ${puppet_metrics_dashboard::telegraf_db_name} DURATION ${puppet_metrics_dashboard::telegraf_db_retention_duration} REPLICATION 1 DEFAULT\"",
      unless => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"SHOW RETENTION POLICIES ON ${puppet_metrics_dashboard::telegraf_db_name}\" | grep -w telegraf_default",
      require => Exec["create influxdb puppet_metrics database ${puppet_metrics_dashboard::telegraf_db_name}"],
    }
  } else {
    exec { "drop existing retention policy if ever created":
      command => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"DROP RETENTION POLICY telegraf_default ON ${puppet_metrics_dashboard::telegraf_db_name}\"",
      onlyif => "influx -username admin -password ${puppet_metrics_dashboard::influx_db_password} -execute \"SHOW RETENTION POLICIES ON ${puppet_metrics_dashboard::telegraf_db_name}\" | grep -w telegraf_default",
    }
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
