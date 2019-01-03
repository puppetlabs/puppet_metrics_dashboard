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
          enabled  => 1,
          gpgcheck => 1,
          baseurl  => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
          gpgkey   => 'https://repos.influxdata.com/influxdb.key',
        }

        yumrepo { 'grafana-repo':
          ensure        => 'present',
          baseurl       => 'https://packagecloud.io/grafana/stable/el/6/$basearch',
          descr         => 'grafana-repository',
          enabled       => '1',
          repo_gpgcheck => '1',
          gpgcheck      => '1',
          gpgkey        => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
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
          location => 'https://packagecloud.io/grafana/stable/debian/',
          release  => 'jessie',
          repos    => 'main',
          key      =>  {
            'id'     => '418A7F2FB0E1E6E7EABF6FE8C2E73424D59097AB',
            'source' => 'https://packagecloud.io/gpg.key',
          },
        }
      }

      default: {
        fail("${facts['os']['family']} installation not supported")
      }
    }
  }
}
