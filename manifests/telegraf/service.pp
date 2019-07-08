# @summary Manages the Telegraf service
#
# Manages the Telegraf service
#
# @api private
class puppet_metrics_dashboard::telegraf::service {
  service { 'telegraf':
    ensure  => running,
    enable  => true,
    require => [
      Service[$puppet_metrics_dashboard::influx_db_service_name]],
  }
}
