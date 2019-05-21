# A metric name corresponding to an endpoint (url)
type Puppet_metrics_dashboard::Puppetdb_metric = Tuple[
  Struct[{
    name => String[1],
    url  => String[1]
  }],
  1,
  default
]
