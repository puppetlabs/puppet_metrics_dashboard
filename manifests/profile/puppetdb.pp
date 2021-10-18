# @summary Apply this class to a node running puppetdb to collect puppetdb metrics
#
# @param timeout
#   Default timeout of http calls.  Defaults to 5 seconds
#
# @param puppetdb_metrics
#   An array of hashes containing name / url pairs for each puppetdb metric.
#   See functions/puppetdb_metrics.pp for defaults.
#
# @param puppetdb_host
#   Where to query the puppetdb host.  Defaults to localhost.
#
# @param port
#   The port that the puppetdb service listens on on your compiler.  Defaults to 8081
#
# @param interval
#   The frequency that telegraf will poll for metrics.  Defaults to '5s'
#
# @param enable_client_cert
#   A boolean to enable using the client certificate for the PuppetDB queries. Defaults to true
#
# @example Add telegraf to a puppetdb node
#   puppet_metrics_dashboard::profile::puppetdb{ $facts['networking']['fqdn']:
#     timeout          => '5s',
#     puppetdb_metrics => puppet_metrics_dashboard::puppetdb_metrics(), # this is the default value
#   }
#
define puppet_metrics_dashboard::profile::puppetdb (
  String[2] $timeout                                          = lookup('puppet_metrics_dashboard::http_response_timeout'),
  Variant[String,Tuple[String, Integer]] $puppetdb_host       = 'localhost',
  Puppet_metrics_dashboard::Puppetdb_metric $puppetdb_metrics = puppet_metrics_dashboard::puppetdb_metrics(),
  Integer[1] $port                                            = 8081,
  String[2] $interval                                         = '5s',
  Boolean $enable_client_cert                                 = true,
  ){

  ensure_resource( 'puppet_metrics_dashboard::certs', 'telegraf', {
      notify  => Service['telegraf'],
      require => Package['telegraf'],
      before  => Service['telegraf'],
  })

  $cert_dir = '/etc/telegraf'
  $default_options = $enable_client_cert ? {
    true => {
      'tls_key'              => "${cert_dir}/${clientcert}_key.pem",
      'tls_cert'             => "${cert_dir}/${clientcert}_cert.pem",
      'tls_ca'               => "${cert_dir}/ca.pem",
      'insecure_skip_verify' => false,
    },
    default => {
      'insecure_skip_verify' => true,
    }
  }

  $protocol = $enable_client_cert ? {
    true    => 'https',
    default => 'http'
  }

  if puppet_metrics_dashboard::puppetdb_v2_metrics() {
        $metrics_version = 'v2/read'
      } else {
        $metrics_version = 'v1/mbeans'
      }

  $server_name = $puppetdb_host ? {
    'localhost' => $clientcert,
    default => $puppetdb_host,
  }

  $puppetdb_metrics.each |$metric| {
    telegraf::input { "puppetdb_${metric['name']}_${puppetdb_host}":
      plugin_type => 'http',
      options     => [{
        'data_format'   => 'json',
        'name_override' => "httpjson_puppetdb_${metric['name']}",
        'method'        => 'GET',
        'urls'          => [ "${protocol}://${puppetdb_host}:${port}/metrics/${metrics_version}/${metric['url']}" ],
        'timeout'       => $timeout,
        'tags'          => {
          'server' => $server_name,
        }
        } + $default_options
      ],
      notify      => Service['telegraf'],
      require     => Package['telegraf'],
    }
  }

  telegraf::input { "puppetdb_command_queue_${puppetdb_host}":
    plugin_type => 'http',
    options     => [{
      'data_format'   => 'json',
      'name_override' => 'httpjson_puppetdb_command_queue',
      'urls'          => [ "${protocol}://${puppetdb_host}:${port}/status/v1/services?level=debug" ],
      'timeout'       => $timeout,
      'tags'          => {
        'server' => $server_name,
      }
      } + $default_options
    ],
    notify      => Service['telegraf'],
    require     => Package['telegraf'],
  }
}
