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
  if ($profile == 'puppetdb') {
    if $settings::storeconfigs {
      # PuppetDB metrics in the following versions can only be reached via localhost
      # PE 2018.1.13 - PE 2019.0.0
      # PE 2019.5 - PE 2019.8.4
      $hosts = puppetdb_query('inventory[certname]{ 
        facts.puppet_metrics_dashboard.versions.puppetdb >= "6.15.0" or
        facts.puppet_metrics_dashboard.versions.puppetdb < "5.2.13"
        }').map |$nodes| { $nodes['certname'] }
    } else {
      $hosts = []
    }
    if empty($hosts) and $facts.dig('puppet_metrics_dashboard', 'versions', 'puppetdb') {
      ['localhost']
    } else {
      sort($hosts)
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
