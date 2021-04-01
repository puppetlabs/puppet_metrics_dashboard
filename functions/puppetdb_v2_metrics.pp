# @summary function used to determine if the metrics v2 endpoint in PuppetDB can be used

function puppet_metrics_dashboard::puppetdb_v2_metrics() >> Boolean {
  if ((versioncmp($facts['puppetversion'], '6.14.0') >= 0) or ((versioncmp($facts['puppetversion'], '5.5.19') >= 0) and (versioncmp($facts['puppetversion'], '6.0.0') < 1))) {
    true
  } else {
    false
  }
}
