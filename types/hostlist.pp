# A list of hostnames, or pairs of hostname and port.
type Puppet_metrics_dashboard::HostList = Array[
  Variant[
    String,
    Tuple[String, Integer]
  ]
]
