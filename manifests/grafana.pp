# @summary Install and configure Grafana
#
# Install and configure Grafana. This work is broken out into its own class
# because it requires the InfluxDB service to be running before it can even
# start doing its thing.
#
# Note: The curl command used to set the password during installation does not
# validate the certificate of the Grafana server.
#
# @api private
class puppet_metrics_dashboard::grafana {
  if $puppet_metrics_dashboard::use_dashboard_ssl {
    $grafana_cfg = {
      server => {
        http_port => $puppet_metrics_dashboard::grafana_http_port,
        protocol  => 'https',
        cert_file => $puppet_metrics_dashboard::dashboard_cert_file,
        cert_key  => $puppet_metrics_dashboard::dashboard_cert_key,
      },
    }

    puppet_metrics_dashboard::certs{'grafana':
      notify  => Service['grafana-server'],
      require => Package['grafana'],
      before  => Service['grafana-server'],
    }

  } else {
    $grafana_cfg = {
      server    => {
        http_port => $puppet_metrics_dashboard::grafana_http_port,
      },
    }
  }

  class { 'grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    version             => $puppet_metrics_dashboard::grafana_version,
    cfg                 => $grafana_cfg,
    require             => Http_conn_validator['influxdb-conn-validator'],
    notify              => Exec['update Grafana admin password'],
  }

  $_uri = $puppet_metrics_dashboard::use_dashboard_ssl ? {
    true    => 'https',
    default => 'http',
  }

  http_conn_validator { 'grafana-conn-validator' :
    host        => 'localhost',
    port        => $puppet_metrics_dashboard::grafana_http_port,
    use_ssl     => $puppet_metrics_dashboard::use_dashboard_ssl,
    test_url    => '/public/img/grafana_icon.svg',
    verify_peer => false,
    try_sleep   => 10,
    require     => Class['grafana'],
  }

  exec { 'update Grafana admin password':
    path        => '/usr/bin',
    command     => @("CHANGE_GRAFANA_PW"),
      curl -k -X PUT -H "Content-Type: application/json" -d '{
        "oldPassword": "${puppet_metrics_dashboard::grafana_old_password}",
        "newPassword": "${puppet_metrics_dashboard::grafana_password}",
        "confirmNew": "${puppet_metrics_dashboard::grafana_password}"
      }' ${_uri}://admin:${puppet_metrics_dashboard::grafana_old_password}@localhost:${puppet_metrics_dashboard::grafana_http_port}/api/user/password
      | CHANGE_GRAFANA_PW
    cwd         => '/usr/share/grafana',
    refreshonly => true,
    require     => Http_conn_validator['grafana-conn-validator'],
  }

  Http_conn_validator <| title == 'grafana-conn-validator' |>
  -> Grafana_datasource <| tag == 'puppet_metrics_dashboard' |>

  Http_conn_validator <| title == 'grafana-conn-validator' |>
  -> Grafana_dashboard <| tag == 'puppet_metrics_dashboard' |>

}
