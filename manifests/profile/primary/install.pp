# @summary Install requirements for the voxpupuli/puppet-telegraf module
#
# Install requirements for the voxpupuli/puppet-telegraf module.
#
# @example Apply this class to the Primary Server and any/all Compilers
#   include puppet_metrics_dashboard::profile::primary::install
#
class puppet_metrics_dashboard::profile::primary::install (
  Boolean $manage_ldap_auth = true,
  ) {

  if $facts['pe_server_version'] {
    $puppetserver_service = 'pe-puppetserver'
  } else {
    $puppetserver_service = 'puppetserver'
  }

  if $manage_ldap_auth {
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
