# @summary Apply this class to a master or compiler to collect puppetserver metrics
#
# @param timeout
#   Deafault timeout of http calls.  Defaults to 5 seconds
#
class puppet_metrics_dashboard::profile::compiler (
  Integer[1] $timeout = $puppet_metrics_dashboard::params::http_response_timeout,
  Integer[1] $port    = 8140,
  ){

  telegraf::input { 'puppetserver_metrics':
    plugin_type => 'httpjson',
    options     => [{
      'name'                 => 'puppet_stats',
      'servers'              => [ "https://${facts['networking']['fqdn']}:${port}/status/v1/services?level=debug" ],
      'method'               => 'GET',
      'insecure_skip_verify' => true,
      'response_timeout'     => "${timeout}s",
    }],
  }

  telegraf::input { 'pe_last_file_sync':
    plugin_type => 'http',
    options     => [{
      'urls'                 => [ "https://${facts['networking']['fqdn']}:${port}/status/v1/services/file-sync-client-service?level=debug" ],
      'insecure_skip_verify' => true,
      'data_format'          => 'json',
      'json_string_fields'   => ['status_repos_puppet-code_latest_commit_date'],
      'timeout'              => "${timeout}s",
    }],
  }
}
