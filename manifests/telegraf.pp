# @summary Install and configure Telegraf
#
# Install and configure Telegraf
#
# @api private
class puppet_metrics_dashboard::telegraf {
  contain puppet_metrics_dashboard::telegraf::install
  contain puppet_metrics_dashboard::telegraf::config
  contain puppet_metrics_dashboard::telegraf::service

  Class['puppet_metrics_dashboard::telegraf::install']
  -> Class['puppet_metrics_dashboard::Telegraf::config']
  -> Class['puppet_metrics_dashboard::Telegraf::service']
}
