# @summary Copy Puppet Agent keypair for use by metric services.
#
# This type creates copies of the Puppet Agent's SSL keypair in `/etc/${service}`
# with user+group ownership set to `${service}`. These certificates are used
# when configuring Grafana to use SSL and to connect Telegraf with PE Services.
#
# @param service
#   The service name to associate with the keypair copy.
#
# @param ssl_dir
#   The directory to copy Puppet Agent SSL files from. Defaults to the
#   value of `puppet config print --section server ssldir` used by the
#   Puppet Server, often `/etc/puppetlabs/puppet/ssl`. Use Hiera to
#   override this value if agents have a different `ssldir` setting
#   or if `bolt apply` is being used.
define puppet_metrics_dashboard::certs (
  $service = $name,
  $ssl_dir = lookup('puppet_metrics_dashboard::certs::ssl_dir',
                    {default_value => $settings::ssldir}),
){
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
