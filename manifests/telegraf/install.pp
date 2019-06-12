# @summary Installs Telegraf
#
# Installs Telegraf
#
# @api private
class puppet_metrics_dashboard::telegraf::install {
  unless $puppet_metrics_dashboard::configure_telegraf {
    package { 'telegraf':
      ensure  => present,
    }
  }
}
