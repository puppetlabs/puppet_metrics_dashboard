# @summary function used to determine if the metrics v2 endpoint in PuppetDB can be used

function puppet_metrics_dashboard::puppetdb_v2_metrics() >> Boolean {
  if versioncmp($facts['puppetversion'], '5.5.19') >= 0 {
    true
  } else {
    false
  }
}
