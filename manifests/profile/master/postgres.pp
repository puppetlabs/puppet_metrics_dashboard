# @summary Aplly this class to an agent running pe-postgresql to collect postgres metrics
#
# @param interval
#   How often to run the queries.  Defaults to 10 minutes.
#
class puppet_metrics_dashboard::profile::master::postgres (
  Integer[1] $interval = 10,
  ){

  telegraf::input { 'pe-postgres':
    plugin_type => 'postgresql_extensible',
    options     => [{
      'interval'      => "${interval}m",
      'address'       => 'postgres://telegraf@localhost/pe-puppetdb?sslmode=disable',
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
  }
}
