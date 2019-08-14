# @summary This class creates a certificates for Grafana and for connecting to PE Postgres.
#
# This class creates a set of certificates in /etc/${service}. These certificates
# are used when configuring Grafana to use SSL and to connect to PE Postgres.
# The certificates are based on the agent's own Puppet certificates.
#
# @param service
#   The service name associated with these certificates.
#
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
    source => "file://${client_pem_key}",
  }

  file { "${cert_dir}/${clientcert}_cert.pem":
    source => "file://${client_cert}",
  }

  file { "${cert_dir}/ca.pem":
    source => "file://${ssl_dir}/certs/ca.pem",
  }
}
