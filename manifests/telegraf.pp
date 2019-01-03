# @summary Install and configure Telegraf
#
# Install and configure Telegraf
#
# @api private
class puppet_metrics_dashboard::telegraf {
  # Enable Telegraf if `configure_telegraf` is true.
  $_enable_telegraf = $puppet_metrics_dashboard::configure_telegraf ? {
    true    => true,
    default => $puppet_metrics_dashboard::enable_telegraf
  }

  if $_enable_telegraf {
    contain puppet_metrics_dashboard::telegraf::install
    contain puppet_metrics_dashboard::telegraf::config
    contain puppet_metrics_dashboard::telegraf::service

    Class['puppet_metrics_dashboard::telegraf::install']
    -> Class['puppet_metrics_dashboard::telegraf::config']
    -> Class['puppet_metrics_dashboard::telegraf::service']
  }
}
