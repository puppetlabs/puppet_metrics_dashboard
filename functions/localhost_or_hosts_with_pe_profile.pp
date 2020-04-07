# @summary function used to determine hosts with a Puppet Enterprise profile
#
# Queries PuppetDB for hosts with the specified Puppet Enterprise profile.
# Used by this module to identify hosts with Puppet Enterprise API endpoints.
#
# @param profile [String]
#   The short name of the Puppet Enterprise profile to query.
#
# @return [Array[String]]
#   An array of certnames from the query, or the local certname when the query returns no hosts.

function puppet_metrics_dashboard::localhost_or_hosts_with_pe_profile(
  String $profile,
) >> Array {
  if ($profile == 'puppetdb') and (puppet_metrics_dashboard::puppetdb_no_remote_metrics()) {
    if $facts['puppet_server'] == $trusted['certname'] {
      $hosts = ['localhost']
    } else {
      $hosts = []
    }
  } else {
    if $settings::storeconfigs {
      $_profile = capitalize($profile)
      $hosts = puppetdb_query("resources[certname] {
        type = 'Class' and
        title = 'Puppet_enterprise::Profile::${_profile}' and
        nodes { deactivated is null and expired is null }
      }").map |$nodes| { $nodes['certname'] }
    } else {
      $hosts = []
    }
    if empty($hosts) {
      [$trusted['certname']]
    } else {
      sort($hosts)
    }
  }

}
