# @summary function used to determine if the metrics endpoint in PuppetDB can be reached remotely or not
#
# In PE 2019.5 or newer with PuppetDB 6.9.1 or newer, or PE 2018.1.13 or newer PE 2018 with PuppetDB 5.2.13 or newer
# As per: https://puppet.com/docs/pe/latest/component_versions_in_recent_pe_releases.html
# PuppetDB metrics in these versions can only be reached via localhost

function puppet_metrics_dashboard::puppetdb_no_remote_metrics() >> Boolean {
  if ((versioncmp($facts['puppetversion'], '6.14.0') >= 0) or ((versioncmp($facts['puppetversion'], '5.5.19') >= 0) and (versioncmp($facts['puppetversion'], '6.0.0') < 1))) {
    true
  } else {
    false
  }
}
