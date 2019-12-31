# @summary Apply this class to a PE PostgreSQL node to allow access by Telegraf.
#
# @param telegraf_host
#   The FQDN of the host running Telegraf. Defaults to an empty string.
#   You can define this parameter, otherwise this class will query PuppetDB for a dashboard host.
#
# @example Apply this class to PE PostgreSQL nodes.
#   class { 'puppet_metrics_dashboard::profile::master::postgres_access':
#     telegraf_host => 'dashboard.example.com',
#   }
#
class puppet_metrics_dashboard::profile::master::postgres_access (
  String $telegraf_host = "" # lint:ignore:double_quoted_strings
){

  # If $telegraf_host is not defined, query PuppetDB for a dashboard host.

  if $telegraf_host.empty {
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
    unless $_query.empty {$_telegraf_host = $_query[0]['certname']}
  } else {
    $_telegraf_host = $telegraf_host
  }

  # If $telegraf_host is not defined and the query fails to find a dashboard host, issue a warning.

  if $_telegraf_host == undef {

    notify { 'You must specify telegraf_host (or apply the puppet_metrics_dashboard class to an agent) to enable access.': }

  } else {

    pe_postgresql::server::role { 'telegraf': }

    pe_postgresql::server::database_grant { 'telegraf':
      privilege => 'CONNECT',
      db        => 'pe-puppetdb',
      role      => 'telegraf',
    }

    # If the fact doesn't exist then PostgreSQL is probably version 9.4.

    if $facts['pe_postgresql_info']['installed_server_version'] {
      $postgres_version = $facts['pe_postgresql_info']['installed_server_version']
    } else {
      $postgres_version = '9.4'
    }

    puppet_enterprise::pg::cert_whitelist_entry { 'allow-telegraf-access':
      user                          => 'telegraf',
      database                      => 'pe-puppetdb',
      allowed_client_certname       => $_telegraf_host,
      pg_ident_conf_path            => "/opt/puppetlabs/server/data/postgresql/${postgres_version}/data/pg_ident.conf",
      ip_mask_allow_all_users_ssl   => '0.0.0.0/0',
      ipv6_mask_allow_all_users_ssl => '::/0',
    }

  }
}
