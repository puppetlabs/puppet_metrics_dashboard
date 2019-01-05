class puppet_metrics_dashboard::profile::postgres (
  String $grafana_host = ''
){

  ##If a value is not supplied, we try a lookup

  if $grafana_host.empty {
    $_query = puppetdb_query('resources[certname] {
      type = "Class" and
      title = "Puppet_metrics_dashboard" and
      nodes {
        deactivated is null and
        expired is null
      }
      order by certname asc
      limit 1
    }')
    unless $_query.empty {$_grafana_host = $_query[0]['certname']}
  } else {
    $_grafana_host = $grafana_host
  }

  ##If no value is supplied _and_ the lookup returns nothing, we issue a warning and do nothing

  if $_grafana_host == undef {

    notify{ 'This class configures access for a telegaf client to connect to pe-postgresql, you must apply the Puppet_metrics_dashboard class must to an agent or set $grafana_host before this can happen.  $grafana_host is undef':}

  } else {

    pe_postgresql::server::role { 'telegraf': }

    pe_postgresql::server::database_grant { 'telegraf':
      privilege => 'CONNECT',
      db        => 'pe-puppetdb',
      role      => 'telegraf',
    }

    ##If this fact doesn't exist then postgres is probably at v9.4

    if $facts['pe_postgresql_info']['installed_server_version'] {
      $postgres_version = $facts['pe_postgresql_info']['installed_server_version']
    } else {
      $postgres_version = '9.4'
    }

    puppet_enterprise::pg::cert_whitelist_entry { 'allow-telegraf-access':
      user                          => 'telegraf',
      database                      => 'pe-puppetdb',
      allowed_client_certname       => $_grafana_host,
      pg_ident_conf_path            => "/opt/puppetlabs/server/data/postgresql/${postgres_version}/data/pg_ident.conf",
      ip_mask_allow_all_users_ssl   => '0.0.0.0/0',
      ipv6_mask_allow_all_users_ssl => '::/0',
    }

  }
}
