# @summary Configures Telegraf
# @api private
class puppet_metrics_dashboard::telegraf (
  Boolean $configure_telegraf         =  $puppet_metrics_dashboard::install::configure_telegraf,
  String $influx_db_service_name      =  $puppet_metrics_dashboard::install::influx_db_service_name,
  Array[String] $master_list          =  $puppet_metrics_dashboard::install::master_list,
  Array[String] $puppetdb_list        =  $puppet_metrics_dashboard::install::puppetdb_list,
  String $influxdb_urls               =  $puppet_metrics_dashboard::install::influxdb_urls,
  String $telegraf_db_name            =  $puppet_metrics_dashboard::install::telegraf_db_name,
  Integer[1] $telegraf_agent_interval =  $puppet_metrics_dashboard::install::telegraf_agent_interval,
  Integer[1] $http_response_timeout   =  $puppet_metrics_dashboard::install::http_response_timeout,
  Array[String] $additional_metrics   = [],
  ) {

  # Taken from https://github.com/puppetlabs/puppetlabs-puppet_metrics_collector/blob/master/manifests/puppetdb.pp
  # Configure the mbean metrics to be collected
  $activemq_metrics = [
  { 'name' => 'amq_metrics',
    'url'  => 'org.apache.activemq:type=Broker,brokerName=localhost,destinationType=Queue,destinationName=puppetlabs.puppetdb.commands' },
  ]

  $base_metrics = [
    { 'name' => 'global_command-parse-time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.command-parse-time' },
    { 'name' => 'global_discarded',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.discarded' },
    { 'name' => 'global_fatal',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.fatal' },
    { 'name' => 'global_generate-retry-message-time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.generate-retry-message-time' },
    { 'name' => 'global_message-persistence-time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.message-persistence-time' },
    { 'name' => 'global_retried',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.retried' },
    { 'name' => 'global_retry-counts',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.retry-counts' },
    { 'name' => 'global_retry-persistence-time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.retry-persistence-time' },
    { 'name' => 'global_seen',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.seen' },
    { 'name' => 'global_processed',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.processed' },
    { 'name' => 'global_processing-time',
      'url'  => 'puppetlabs.puppetdb.mq:name=global.processing-time' },
  ]

  $storage_metrics = [
    { 'name' => 'storage_add-edges',
      'url'  => 'puppetlabs.puppetdb.storage:name=add-edges' },
    { 'name' => 'storage_add-resources',
      'url'  => 'puppetlabs.puppetdb.storage:name=add-resources' },
    { 'name' => 'storage_catalog-hash',
      'url'  => 'puppetlabs.puppetdb.storage:name=catalog-hash' },
    { 'name' => 'storage_catalog-hash-match-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=catalog-hash-match-time' },
    { 'name' => 'storage_catalog-hash-miss-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=catalog-hash-miss-time' },
    { 'name' => 'storage_gc-catalogs-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-catalogs-time' },
    { 'name' => 'storage_gc-environments-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-environments-time' },
    { 'name' => 'storage_gc-fact-paths',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-fact-paths' },
    { 'name' => 'storage_gc-params-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-params-time' },
    { 'name' => 'storage_gc-report-statuses',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-report-statuses' },
    { 'name' => 'storage_gc-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=gc-time' },
    { 'name' => 'storage_new-catalog-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=new-catalog-time' },
    { 'name' => 'storage_new-catalogs',
      'url'  => 'puppetlabs.puppetdb.storage:name=new-catalogs' },
    { 'name' => 'storage_replace-catalog-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=replace-catalog-time' },
    { 'name' => 'storage_replace-facts-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=replace-facts-time' },
    { 'name' => 'storage_resource-hashes',
      'url'  => 'puppetlabs.puppetdb.storage:name=resource-hashes' },
    { 'name' => 'storage_store-report-time',
      'url'  => 'puppetlabs.puppetdb.storage:name=store-report-time' },
  ]

  #TODO: Track these on a less frequent cadence because they are slow to run
  $storage_metrics_db_queries = [
    { 'name' => 'storage_catalog-volitilty',
      'url'  => 'puppetlabs.puppetdb.storage:name=catalog-volitilty' },
    { 'name' => 'storage_duplicate-catalogs',
      'url'  => 'puppetlabs.puppetdb.storage:name=duplicate-catalogs' },
    { 'name' => 'storage_duplicate-pct',
      'url'  => 'puppetlabs.puppetdb.storage:name=duplicate-pct' },
  ]

  $numbers = $facts['pe_server_version'] ? {
    /^2015.2/     => {'catalogs' => 6, 'facts' => 4, 'reports' => 6},
    /^2015.3/     => {'catalogs' => 7, 'facts' => 4, 'reports' => 6},
    /^2016.(1|2)/ => {'catalogs' => 8, 'facts' => 4, 'reports' => 7},
    /^2016.(4|5)/ => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
    /^2017.(1|2)/ => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
    default       => {'catalogs' => 9, 'facts' => 5, 'reports' => 8},
  }

  $version_specific_metrics = [
    { 'name' => 'mq_replace_catalog_retried',
      'url'  => "puppetlabs.puppetdb.mq:name=replace catalog.${numbers['catalogs']}.retried" },
    { 'name' => 'mq_replace_catalog_retry-counts',
      'url'  => "puppetlabs.puppetdb.mq:name=replace catalog.${numbers['catalogs']}.retry-counts" },
    { 'name' => 'mq_replace_facts_retried',
      'url'  => "puppetlabs.puppetdb.mq:name=replace facts.${numbers['facts']}.retried" },
    { 'name' => 'mq_replace_facts_retry-counts',
      'url'  => "puppetlabs.puppetdb.mq:name=replace facts.${numbers['facts']}.retry-counts" },
    { 'name' => 'mq_store_report_retried',
      'url'  => "puppetlabs.puppetdb.mq:name=store report.${numbers['reports']}.retried" },
    { 'name' => 'mq_store_reports_retry-counts',
      'url'  => "puppetlabs.puppetdb.mq:name=store report.${numbers['reports']}.retry-counts" },
  ]

  $connection_pool_metrics = [
    { 'name' => 'PDBReadPool_pool_ActiveConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.ActiveConnections' },
    { 'name' => 'PDBReadPool_pool_IdleConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.IdleConnections' },
    { 'name' => 'PDBReadPool_pool_PendingConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.PendingConnections' },
    { 'name' => 'PDBReadPool_pool_TotalConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.TotalConnections' },
    { 'name' => 'PDBReadPool_pool_Usage',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.Usage' },
    { 'name' => 'PDBReadPool_pool_Wait',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBReadPool.pool.Wait' },
    { 'name' => 'PDBWritePool_pool_ActiveConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.ActiveConnections' },
    { 'name' => 'PDBWritePool_pool_IdleConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.IdleConnections' },
    { 'name' => 'PDBWritePool_pool_PendingConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.PendingConnections' },
    { 'name' => 'PDBWritePool_pool_TotalConnections',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.TotalConnections' },
    { 'name' => 'PDBWritePool_pool_Usage',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.Usage' },
    { 'name' => 'PDBWritePool_pool_Wait',
      'url'  => 'puppetlabs.puppetdb.database:name=PDBWritePool.pool.Wait' },
  ]

  $ha_sync_metrics = [
    { 'name' => 'ha_last-sync-succeeded',
      'url'  => 'puppetlabs.puppetdb.ha:name=last-sync-succeeded' },
    { 'name' => 'ha_seconds-since-last-successful-sync',
      'url'  => 'puppetlabs.puppetdb.ha:name=seconds-since-last-successful-sync' },
    { 'name' => 'ha_failed-request-counter',
      'url'  => 'puppetlabs.puppetdb.ha:name=failed-request-counter' },
    { 'name' => 'ha_sync-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=sync-duration' },
    { 'name' => 'ha_catalogs-sync-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=catalogs-sync-duration' },
    { 'name' => 'ha_reports-sync-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=reports-sync-duration' },
    { 'name' => 'ha_factsets-sync-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=factsets-sync-duration' },
    { 'name' => 'ha_nodes-sync-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=nodes-sync-duration' },
    { 'name' => 'ha_record-transfer-duration',
      'url'  => 'puppetlabs.puppetdb.ha:name=record-transfer-duration' },
  ]

  $puppetdb_metrics = $facts['pe_server_version'] ? {
    /^2015./ =>
      $activemq_metrics,
    /^2016\.[45]\./ =>
      $activemq_metrics + $base_metrics + $storage_metrics + $connection_pool_metrics + $version_specific_metrics + $ha_sync_metrics,
    /^2016./ =>
      $activemq_metrics + $base_metrics + $storage_metrics + $connection_pool_metrics + $version_specific_metrics,
    /^201[78]\./ =>
      $activemq_metrics + $base_metrics + $storage_metrics + $connection_pool_metrics + $version_specific_metrics + $ha_sync_metrics,
    default  =>
      $base_metrics + $storage_metrics + $connection_pool_metrics + $version_specific_metrics,
  }

  package { 'telegraf':
    ensure  => present,
    require => Class['puppet_metrics_dashboard::repos'],
  }

  service { 'telegraf':
    ensure  => running,
    enable  => true,
    require => [Package['telegraf'], Service[$influx_db_service_name]],
  }

  if $configure_telegraf {
    $global_config_file = '/etc/telegraf/telegraf.conf'
    $telegraf_agent_settings = {
      'interval'            => "'${telegraf_agent_interval}s'",
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
      'urls'              => $influxdb_urls,
      'database'          => "'${telegraf_db_name}'",
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

    file {'/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf':
      ensure  => file,
      owner   => 0,
      group   => 0,
      content => epp('puppet_metrics_dashboard/telegraf.conf.epp',
        {
          puppetdb_metrics      => $puppetdb_metrics,
          master_list           => $master_list,
          puppetdb_list         => $puppetdb_list,
          http_response_timeout => $http_response_timeout,
        }),
      notify  => Service['telegraf'],
      require => Package['telegraf'],
    }
  }
}
