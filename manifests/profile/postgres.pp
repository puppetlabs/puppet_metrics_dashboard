class puppet_metrics_dashboard::profile::postgres (
  Sensitive[String] $pg_password = Sensitive($puppet_metrics_dashboard::postgres_password),
){

  pe_postgresql::server::pg_hba_rule{ 'allow telegraf user':
    type        => 'hostnossl',
    database    => 'pe-puppetdb',
    user        => 'telegraf',
    auth_method => 'password',
    address     => '192.168.0.8/32',
  }

  pe_postgresql::server::role { 'telegraf':
    password_hash => pe_postgresql_password('telegraf', $pg_password),
  }

  pe_postgresql::server::database_grant { 'telegraf':
    privilege => 'CONNECT',
    db        => 'pe-puppetdb',
    role      => 'telegraf',
  }

}
