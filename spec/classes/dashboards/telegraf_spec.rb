require 'spec_helper'

describe 'puppet_metrics_dashboard::dashboards::telegraf' do
  let(:pre_condition) do
    <<-PRE_COND
      class {'puppet_metrics_dashboard':
        add_dashboard_examples => false,
        influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
      }
    PRE_COND
  end

  let(:params) do
    {
      'grafana_port' => 3000,
      'grafana_password' => 'puppetlabs',
      'use_dashboard_ssl' => false,
    }
  end

  it do
    is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Performance').with(
      grafana_url: 'http://localhost:3000',
      grafana_user: 'admin',
      grafana_password: 'puppetlabs',
      require: 'Grafana_datasource[influxdb_telegraf]',
    )
  end

  it do
    is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Workload').with(
      grafana_url: 'http://localhost:3000',
      grafana_user: 'admin',
      grafana_password: 'puppetlabs',
      require: 'Grafana_datasource[influxdb_telegraf]',
    )
  end

  it do
    is_expected.to contain_grafana_dashboard('Telegraf Puppetserver Performance').with(
      grafana_url: 'http://localhost:3000',
      grafana_user: 'admin',
      grafana_password: 'puppetlabs',
      require: 'Grafana_datasource[influxdb_telegraf]',
    )
  end

  it do
    is_expected.to contain_grafana_dashboard('Telegraf File Sync Metrics').with(
      grafana_url: 'http://localhost:3000',
      grafana_user: 'admin',
      grafana_password: 'puppetlabs',
      require: 'Grafana_datasource[influxdb_telegraf]',
    )
  end
end
