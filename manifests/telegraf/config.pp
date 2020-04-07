# @summary Configures Telegraf
#
# Configures settings in telegraf.conf via ini_setting resources.
# Manages all module-specific settings in
# `telegraf.d/puppet_metrics_dashboard.conf`.
#
# @api private
class puppet_metrics_dashboard::telegraf::config {
  if $puppet_metrics_dashboard::configure_telegraf {
    $_puppetdb_metrics = $puppet_metrics_dashboard::puppetdb_metrics

    class { 'telegraf':
      interval       => $puppet_metrics_dashboard::telegraf_agent_interval,
      logfile        => '/var/log/telegraf/telegraf.log',
      hostname       => '',
      manage_repo    => false,
      manage_service => false,
      outputs        => {
        'influxdb' => [
          {
            'urls'              => $puppet_metrics_dashboard::influxdb_urls,
            'database'          => $puppet_metrics_dashboard::telegraf_db_name,
            'write_consistency' => 'any',
            'timeout'           => '5s',
          },
        ],
      },
    }

    file {'/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf':
      ensure => absent,
    }

    # Transform the host lists into arrays of "hostname:port", using a
    # service's default port if no alternate was specified.
    $_master_list = $puppet_metrics_dashboard::master_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => { 'host' => $entry[0], 'port' => $entry[1] },
        String                 => { 'host' => $entry, 'port' => 8140 },
      }
    }
    $_puppetdb_list = $puppet_metrics_dashboard::puppetdb_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => { 'host' => $entry[0], 'port' => $entry[1] },
        String                 => { 'host' => $entry, 'port' => 8081 },
      }
    }
    $_postgres_list = $puppet_metrics_dashboard::postgres_host_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => { 'host' => $entry[0], 'port' => $entry[1] },
        String                 => { 'host' => $entry, 'port' => 5432 },
      }
    }

    $_master_list.each |$master| {
      puppet_metrics_dashboard::profile::compiler{ $master['host']:
        compiler => $master['host'],
        port     => $master['port'],
        timeout  => $puppet_metrics_dashboard::http_response_timeout,
        interval => $puppet_metrics_dashboard::telegraf_agent_interval,
      }
    }

    $_puppetdb_list.each |$puppetdb| {
      $enable_client_cert = $puppetdb['host'] ? {
          'localhost' => false,
          default     => true,
        }
      puppet_metrics_dashboard::profile::puppetdb{ $puppetdb['host']:
        puppetdb_host      => $puppetdb['host'],
        port               => $puppetdb['port'],
        timeout            => $puppet_metrics_dashboard::http_response_timeout,
        interval           => $puppet_metrics_dashboard::telegraf_agent_interval,
        enable_client_cert => $enable_client_cert,
      }
    }

    $_postgres_list.each |$postgres| {
      puppet_metrics_dashboard::profile::master::postgres{ $postgres['host']:
        postgres_host  => $postgres['host'],
        port           => $postgres['port'],
        query_interval => $puppet_metrics_dashboard::pg_query_interval,
      }
    }

    tidy { 'clean /etc/telegraf/telegraf.d':
      path    => '/etc/telegraf/telegraf.d',
      recurse => true,
    }
  }

}
