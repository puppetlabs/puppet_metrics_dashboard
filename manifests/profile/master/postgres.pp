# @summary Apply this class to an agent running pe-postgresql to collect postgres metrics
#
# @param query_interval
#   How often to run the queries in minutes.  Defaults to 10 minutes.
#
# @param postgres_host
#   The FQDN of the postgres host.  Defaults to the FQDN of the server where the profile is applied
#
# @param port
#   The port that the postgres service listens on.  Defaults to 5432
#
# @example Add telegraf to a postgres server
#   puppet_metrics_dashboard::profile::master::postgres{ $facts['networking']['fqdn']:
#     query_interval => '10m',
#   }
#
define puppet_metrics_dashboard::profile::master::postgres (
  Variant[String,Tuple[String, Integer]] $postgres_host = $facts['networking']['fqdn'],
  String[2] $query_interval                             = lookup('puppet_metrics_dashboard::pg_query_interval'),
  Integer[1] $port                                      = 5432,
  ){

  if ! defined(Puppet_metrics_dashboard::Certs['telegraf']) {
    puppet_metrics_dashboard::certs{'telegraf':
      notify  => Service['telegraf'],
      require => Package['telegraf'],
      before  => Service['telegraf'],
    }
  }

  telegraf::input { "pe_postgres_${postgres_host}":
    plugin_type => 'postgresql_extensible',
    options     => [{
      'interval'      => $query_interval,
      'address'       => "postgres://telegraf@${postgres_host}:${port}/pe-puppetdb?sslmode=require&sslkey=/etc/telegraf/${trusted['certname']}_key.pem&sslcert=/etc/telegraf/${trusted['certname']}_cert.pem&sslrootcert=/etc/telegraf/ca.pem",
      'outputaddress' => $facts['networking']['fqdn'],
      'databases'     => ['pe-puppetdb','pe-rbac','pe-activity','pe-classifier'],
      'query'         => [{
        'sqlquery'   => 'SELECT * FROM pg_stat_database',
        'version'    => 901,
        'withdbname' => false,
        },{
        'sqlquery'   => 'SELECT relname as s_table, pg_relation_size(relid) as size FROM pg_catalog.pg_statio_user_tables ORDER BY pg_total_relation_size(relid) DESC',
        'version'    => 901,
        'withdbname' => false,
        'tagvalue'   => 's_table',
        },{
        'sqlquery'   => 'SELECT relname as v_table, autovacuum_count, vacuum_count, n_live_tup, n_dead_tup FROM pg_stat_user_tables',
        'version'    => 901,
        'withdbname' => false,
        'tagvalue'   => 'v_table',
        },{
        'sqlquery'   => 'SELECT relname as io_table, heap_blks_read, heap_blks_hit, idx_blks_read, idx_blks_hit, toast_blks_read, toast_blks_hit, tidx_blks_read, tidx_blks_hit FROM pg_statio_user_tables',
        'version'    => 901,
        'withdbname' => false,
        'tagvalue'   => 'io_table',
        }]
    }],
    notify      => Service['telegraf'],
    require     => Package['telegraf'],
  }
}
