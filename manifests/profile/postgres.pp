class puppet_metrics_dashboard::profile::postgres (
) inherits puppet_enterprise::profile::database {

  ## Potential problem: we really want only one certname out of this
  $grafana_host = puppetdb_query('resources[certname] {
                        type = "Class" and
                        title = "Puppet_metrics_dashboard" and
                        nodes { 
                          deactivated is null and
                          expired is null
                        }
                      }')[0]['certname']

  pe_postgresql::server::role { 'telegraf':}

  pe_postgresql::server::database_grant { 'telegraf':
    privilege => 'CONNECT',
    db        => 'pe-puppetdb',
    role      => 'telegraf',
  }

  puppet_enterprise::pg::cert_whitelist_entry { "allow-telegraf-access":
    user                          => 'telegraf',
    database                      => 'pe-puppetdb',
    allowed_client_certname       => $grafana_host,
    pg_ident_conf_path            => $pg_ident_conf_path,
    ip_mask_allow_all_users_ssl   => $ip_mask_allow_all_users_ssl,
    ipv6_mask_allow_all_users_ssl => $ipv6_mask_allow_all_users_ssl,
  }

}
