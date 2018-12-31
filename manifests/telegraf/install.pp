# @summary Installs Telegraf
#
# Installs Telegraf
#
# @api private
class puppet_metrics_dashboard::telegraf::install {
  package { 'telegraf':
    ensure  => present,
  }
}
