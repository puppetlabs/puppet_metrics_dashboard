# @summary Install requirements for the voxpupuli/puppet-telegraf module.
#
# @example Apply this class to the Master and any/all Compilers.
#   include puppet_metrics_dashboard::profile::master::install
#
class puppet_metrics_dashboard::profile::master::install {
  $puppetserver_service = $facts['pe_server_version'] ? {
    /./     => 'pe-puppetserver',
    default => 'puppetserver',
  }

  package { 'toml-rb':
    ensure   => present,
    provider => 'puppetserver_gem',
    notify   => Service[$puppetserver_service],
  }
}
