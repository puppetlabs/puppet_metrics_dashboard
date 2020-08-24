# @summary Installs InfluxDB components.
#
# Installs InfluxDB components.
#
# @api private
class puppet_metrics_dashboard::install {

  $_chronograf_ensure = $puppet_metrics_dashboard::enable_chronograf ? {
    true    => present,
    default => absent
  }

  $_kapacitor_ensure = $puppet_metrics_dashboard::enable_kapacitor ? {
    true    => present,
    default => absent
  }

  case $facts['os']['family'] {
    'Suse': {
      file { '/opt/influxdb':
        ensure => directory,
      }
      archive { '/tmp/influxdb.tar.gz':
        ensure          => present,
        extract         => true,
        extract_command => 'tar xfz %s --strip-components=2',
        extract_path    => '/opt/influxdb',
        source          => $puppet_metrics_dashboard::influx_archive_source,
        cleanup         => true,
      }
      group { 'influxdb':
        ensure => present,
      }
      user { 'influxdb':
        ensure => present,
        gid    => 'influxdb',
      }
      file { '/var/lib/influxdb':
        ensure => directory,
        owner  => 'influxdb',
        group  => 'influxdb',
      }
    }
    default: {
      package { 'influxdb':
        ensure => present,
      }

      package { 'kapacitor':
        ensure => $_kapacitor_ensure,
      }

      package { 'chronograf':
        ensure => $_chronograf_ensure,
      }
    }
  }
}
