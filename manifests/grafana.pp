# @summary Install and configure Grafana
#
# Install and configure Grafana. This work is broken out into its own class
# because it requires the InfluxDB service to be running before it can even
# start doing its thing.
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
  }

  if $puppet_metrics_dashboard::enable_ldap_auth {
    $grafana_cfg = {
      'auth.ldap'       => {
        'enabled'       => true,
        'config_file'   => '/etc/grafana/ldap.toml',
        'allow_sign_up' => true,
      },
    }

  } else {
    $grafana_cfg = {
      server    => {
        http_port => $puppet_metrics_dashboard::grafana_http_port,
      },
    }
  }

  $_grafana_cfg = $grafana_cfg.merge({
    'security' => {
      'admin_user'     => 'admin',
      'admin_password' => $puppet_metrics_dashboard::grafana_password,
    }
  }).merge($puppet_metrics_dashboard::grafana_config) # Merge any custom config over the top finally

  class { 'grafana':
    install_method      => 'repo',
    manage_package_repo => false,
    version             => $puppet_metrics_dashboard::grafana_version,
    cfg                 => $_grafana_cfg,
    require             => Service[$puppet_metrics_dashboard::influx_db_service_name],
  }
}
