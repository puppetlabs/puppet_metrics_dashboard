define puppet_metrics_dashboard::certs(
  $service = $name
){

  $ssl_dir        = $settings::ssldir
  $cert_dir       = "/etc/${service}"
  $client_pem_key = "${ssl_dir}/private_keys/${trusted['certname']}.pem"
  $client_cert    = "${ssl_dir}/certs/${trusted['certname']}.pem"

  File {
    owner   => $service,
    group   => $service,
    mode    => '0400',
  }

  file { "${cert_dir}/${clientcert}_key.pem":
    source => $client_pem_key,
  }

  file { "${cert_dir}/${clientcert}_cert.pem":
    source => $client_cert,
  }

  file { "${cert_dir}/ca.pem":
    source => "${ssl_dir}/certs/ca.pem",
  }
}
