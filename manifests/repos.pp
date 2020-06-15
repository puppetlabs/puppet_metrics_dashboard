# @summary Configures InfluxDB and Grafana repos
#
# Configures InfluxDB and Grafana repos
#
# @api private
class puppet_metrics_dashboard::repos {
  if $puppet_metrics_dashboard::manage_repos {
    case $facts['os']['family'] {
      'RedHat': {
        yumrepo {'influxdb':
          ensure   => present,
          descr    => 'influxdb-repository',
          enabled  => 1,
          gpgcheck => 1,
          baseurl  => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
          gpgkey   => 'https://repos.influxdata.com/influxdb.key',
        }

        yumrepo { 'grafana-repo':
          ensure        => 'present',
          baseurl       => 'https://packages.grafana.com/oss/rpm',
          descr         => 'grafana-repository',
          enabled       => '1',
          repo_gpgcheck => '1',
          gpgcheck      => '1',
          gpgkey        => 'https://packages.grafana.com/gpg.key',
          sslverify     => '1',
          sslcacert     => '/etc/pki/tls/certs/ca-bundle.crt',
        }
      }

      'Debian': {
        $_operatingsystem = downcase($facts['os']['name'])
        $_oscodename = downcase($facts['os']['distro']['codename'])

        apt::source { 'influxdb':
          location => "https://repos.influxdata.com/${_operatingsystem}",
          release  => $_oscodename,
          repos    => 'stable',
          key      =>  {
            'id'     => '05CE15085FC09D18E99EFB22684A14CF2582E0C5',
            'source' => 'https://repos.influxdata.com/influxdb.key',
          },
        }

        apt::source { 'grafana':
          location => 'https://packages.grafana.com/oss/deb',
          release  => 'stable',
          repos    => 'main',
          key      =>  {
            'id'     => '4E40DDF6D76E284A4A6780E48C8C34C524098CB6',
            'source' => 'https://packages.grafana.com/gpg.key',
          },
        }
      }

      default: {
        fail("${facts['os']['family']} installation not supported")
      }
    }
  }
}
