# @summary Install requirements for the voxpupuli/puppet-telegraf module
#
# Install requirements for the voxpupuli/puppet-telegraf module.
#
# @example Apply this class to the Master and any/all Compilers
#   include puppet_metrics_dashboard::profile::master::install
#
class puppet_metrics_dashboard::profile::master::install {
  if $facts['pe_server_version'] {
    $puppetserver_service = 'pe-puppetserver'
  } else {
    $puppetserver_service = 'puppetserver'
  }

  if $puppet_metrics_dashboard::enable_ldap_auth {
    package { 'toml':
      ensure   => present,
      provider => 'puppetserver_gem',
      notify   => Service[$puppetserver_service],
    }
  }

  package { 'toml-rb':
    ensure   => present,
    provider => 'puppetserver_gem',
    notify   => Service[$puppetserver_service],
  }
}
