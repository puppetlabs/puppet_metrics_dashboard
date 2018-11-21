class puppet_metrics_dashboard::certs{
  
  $ssl_dir        = $::settings::ssldir 
  $cert_dir       = "/etc/telegraf"
  $client_pem_key = "${ssl_dir}/private_keys/${fqdn}.pem"
  $client_cert    = "${ssl_dir}/certs/${fqdn}.pem"

  File {
    owner   => telegraf,
    group   => telegraf,
    mode    => '0400',
  }

  file { "${cert_dir}/${fqdn}.private_key.pem":
    source => $client_pem_key,
  }

  file { "${cert_dir}/${fqdn}.public_key.pem":
    source => "${ssl_dir}/certs/${fqdn}.pem",
  }

  file { "${cert_dir}/ca.pem":
    source => "${ssl_dir}/certs/ca.pem",
  }
}
