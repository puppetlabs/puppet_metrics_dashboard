# @summary Apply this class to a master or compiler to collect puppetserver metrics
#
# @param timeout
#   Deafault timeout of http calls.  Defaults to 5 seconds
#
# @param compiler
#   The FQDN of the compiler / master.  Defaults to the FQDN of the server where the profile is applied
#
# @param port
#   The port that the puppetserver service listens on on your compiler.  Defaults to 8140
#
# @param interval
#   The frequency that telegraf will poll for metrics.  Defaults to '5s'
#
# @example Add telegraf to a master / compiler
#   puppet_metrics_dashboard::profile::compiler{ $facts['networking']['fqdn']:
#     timeout => '5s',
#   }
#
define puppet_metrics_dashboard::profile::compiler (
  String[2] $timeout                               = lookup('puppet_metrics_dashboard::http_response_timeout'),
  Variant[String,Tuple[String, Integer]] $compiler = $facts['networking']['fqdn'],
  Integer[1] $port                                 = 8140,
  String[2] $interval                              = '5s',
  ){

  telegraf::input { "puppetserver_metrics_${compiler}":
    plugin_type => 'httpjson',
    options     => [{
      'name'                 => 'puppet_stats',
      'servers'              => [ "https://${compiler}:${port}/status/v1/services?level=debug" ],
      'method'               => 'GET',
      'insecure_skip_verify' => true,
      'response_timeout'     => $timeout,
    }],
    notify      => Service['telegraf'],
    require     => Package['telegraf'],
  }

  telegraf::input { "pe_last_file_sync_${compiler}":
    plugin_type => 'http',
    options     => [{
      'urls'                 => [ "https://${compiler}:${port}/status/v1/services/file-sync-client-service?level=debug" ],
      'insecure_skip_verify' => true,
      'data_format'          => 'json',
      'json_string_fields'   => ['status_repos_puppet-code_latest_commit_date'],
      'timeout'              => $timeout,
    }],
    notify      => Service['telegraf'],
    require     => Package['telegraf'],
  }
}
