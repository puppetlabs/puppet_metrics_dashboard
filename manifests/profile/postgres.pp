class puppet_metrics_dashboard::profile::postgres (
){

  $grafana_host = puppetdb_query('resources[certname] {
    type = "Class" and
    title = "Puppet_metrics_dashboard" and
    nodes { 
      deactivated is null and
      expired is null
    }
    order by certname asc
    limit 1
  }')[0]['certname']

  pe_postgresql::server::role { 'telegraf':}

  pe_postgresql::server::database_grant { 'telegraf':
    privilege => 'CONNECT',
    db        => 'pe-puppetdb',
    role      => 'telegraf',
  }

  puppet_enterprise::pg::cert_whitelist_entry { 'allow-telegraf-access':
    user                          => 'telegraf',
    database                      => 'pe-puppetdb',
    allowed_client_certname       => $grafana_host,
    pg_ident_conf_path            => $puppet_enterprise::profile::database::pg_ident_conf_path,
    ip_mask_allow_all_users_ssl   => $puppet_enterprise::profile::database::ip_mask_allow_all_users_ssl,
    ipv6_mask_allow_all_users_ssl => $puppet_enterprise::profile::database::ipv6_mask_allow_all_users_ssl,
  }

}
