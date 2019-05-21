# @summary Apply this class to a master or compiler to collect puppetserver metrics
#
# @param timeout
#   Default timeout of http calls.  Defaults to 5 seconds
#
# @param puppetdb_metrics
#   An array of hashes containing name / url pairs for each puppetdb metric.  See params.pp for defaults.
#
class puppet_metrics_dashboard::profile::puppetdb (
  Integer[1] $timeout                                         = $puppet_metrics_dashboard::params::http_response_timeout,
  Integer[1] $port                                            = 8081,
  Puppet_metrics_dashboard::Puppetdb_metric $puppetdb_metrics = $puppet_metrics_dashboard::params::puppetdb_metrics,
  ) inherits puppet_metrics_dashboard::params {

  $puppetdb_metrics.each |$metric| {
    telegraf::input { "puppetdb_${metric['name']}":
      plugin_type => 'httpjson',
      options     => [{
        'name'                 => "puppetdb_${metric['name']}",
        'method'               => 'GET',
        'servers'              => [ "https://${facts['networking']['fqdn']}:${port}/metrics/v1/mbeans/${metric['url']}" ],
        'insecure_skip_verify' => true,
        'response_timeout'     => "${timeout}s",
      }],
    }
  }
}
