require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_metrics_dashboard':
        influxdb_database_name => ['telegraf'],
        configure_telegraf  => true,
        enable_telegraf     => true,
      }
    PRE_COND
  end

  it do
    is_expected.to contain_package('telegraf').with(
      ensure: 'present',
      require: 'Class[Puppet_metrics_dashboard::Repos]',
    )
  end

  it do
    is_expected.to contain_service('telegraf').with(
      ensure: 'running',
      enable: true,
      require: ['Package[telegraf]', 'Service[influxdb]'],
    )
  end

  it do
    is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf').with(
      ensure: 'file',
      owner: '0',
      group: '0',
      notify: 'Service[telegraf]',
      require: 'Package[telegraf]',
    )
  end
end
