# @summary Configures Telegraf
#
# Configures settings in telegraf.conf via ini_setting resources.
# Manages all module-specific settings in
# `telegraf.d/puppet_metrics_dashboard.conf`.
#
# @api private
class puppet_metrics_dashboard::telegraf::config {
  if $puppet_metrics_dashboard::configure_telegraf {
    $global_config_file = '/etc/telegraf/telegraf.conf'
    $telegraf_agent_settings = {
      'interval'            => "'${puppet_metrics_dashboard::telegraf_agent_interval}s'",
      'round_interval'      => true,
      'metric_batch_size'   => 1000,
      'metric_buffer_limit' => 10000,
      'collection_jitter'   => "'0s'",
      'flush_interval'      => "'10s'",
      'flush_jitter'        => "'0s'",
      'precision'           => "''",
      'debug'               => false,
      'quiet'               => false,
      'logfile'             => "'/var/log/telegraf/telegraf.log'",
      'hostname'            => "''",
      'omit_hostname'       => false,
    }

    $telegraf_agent_settings.each |$k, $v| {
      ini_setting { "telegraf agent - ${k}":
        path         => $global_config_file,
        section      => 'agent',
        setting      => $k,
        value        => $v,
        indent_width => 2,
        notify       => Service['telegraf'],
      }
    }

    $telegraf_influx_output = {
      'urls'              => $puppet_metrics_dashboard::influxdb_urls,
      'database'          => "'${puppet_metrics_dashboard::telegraf_db_name}'",
      'retention_policy'  => "''",
      'write_consistency' => "'any'",
      'timeout'           => "'5s'",
    }

    $telegraf_influx_output.each |$k, $v| {
      ini_setting { "telegraf outputs.influxdb - ${k}":
        path           => $global_config_file,
        section        => 'outputs.influxdb',
        section_prefix => '[[',
        section_suffix => ']]',
        setting        => $k,
        value          => $v,
        indent_width   => 2,
        notify         => Service['telegraf'],
      }
    }

    $_puppetdb_metrics = $puppet_metrics_dashboard::puppetdb_metrics

    puppet_metrics_dashboard::certs{'telegraf':
      notify  => Service['telegraf'],
      require => Package['telegraf'],
      before  => Service['telegraf'],
    }

    # Transform the host lists into arrays of "hostname:port", using a
    # service's default port if no alternate was specified.
    $_master_list = $puppet_metrics_dashboard::master_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => "${entry[0]}:${entry[1]}",
        String                 => "${entry}:8140"
      }
    }
    $_puppetdb_list = $puppet_metrics_dashboard::puppetdb_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => "${entry[0]}:${entry[1]}",
        String                 => "${entry}:8081"
      }
    }
    $_postgres_list = $puppet_metrics_dashboard::postgres_host_list.map |$entry| {
      $entry ? {
        Tuple[String, Integer] => "${entry[0]}:${entry[1]}",
        String                 => "${entry}:5432"
      }
    }

    file {'/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      content => epp('puppet_metrics_dashboard/telegraf.conf.epp',
        {
          puppetdb_metrics      => $_puppetdb_metrics,
          master_list           => $_master_list,
          puppetdb_list         => $_puppetdb_list,
          postgres_host_list    => $_postgres_list,
          http_response_timeout => $puppet_metrics_dashboard::http_response_timeout,
        }),
      notify  => Service['telegraf'],
      require => Package['telegraf'],
    }
  }
}
