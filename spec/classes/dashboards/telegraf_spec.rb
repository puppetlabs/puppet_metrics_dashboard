require 'spec_helper'

describe 'puppet_metrics_dashboard::dashboards::telegraf' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      let(:pre_condition) do
        <<-PRE_COND
          function puppet_metrics_dashboard::puppetdb_no_remote_metrics() { false }
          class {'puppet_metrics_dashboard':
            add_dashboard_examples => false,
            influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
            grafana_password       => 'puppetlabs',
            puppetdb_list          => [],
          }
        PRE_COND
      end

      # rubocop:disable RSpec/ExampleWording
      it 'should contain Grafana_dashboard[Telegraf PuppetDB Performance]' do
        is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
          content: %r{"FiveMinuteRate"},
        )
      end

      it 'should contain Grafana_dashboard[Telegraf PuppetDB Workload]' do
        is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Workload').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
          content: %r{"999thPercentile"},
        )
      end

      it 'should contain Grafana_dashboard[Telegraf Puppetserver Performance]' do
        is_expected.to contain_grafana_dashboard('Telegraf Puppetserver Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
        )
      end

      it 'should contain Grafana_dashboard[Telegraf Puppetserver Workload]' do
        is_expected.to contain_grafana_dashboard('Telegraf Puppetserver Workload').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
        )
      end

      it 'should contain Grafana_dashboard[Telegraf File Sync Metrics]' do
        is_expected.to contain_grafana_dashboard('Telegraf File Sync Metrics').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
        )
      end

      it 'should contain Grafana_dashboard[Telegraf Postgres Metrics]' do
        is_expected.to contain_grafana_dashboard('Telegraf Postgres Metrics').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_telegraf]',
        )
      end

      context 'when PuppetDB is localhost on a newer version of Puppet' do
        let(:pre_condition) do
          <<-PRE_COND
            function puppet_metrics_dashboard::puppetdb_no_remote_metrics() { true }
            class {'puppet_metrics_dashboard':
              add_dashboard_examples => false,
              influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
              grafana_password       => 'puppetlabs',
              puppetdb_list          => ['localhost'],
            }
          PRE_COND
        end

        it 'should contain Grafana_dashboard[Telegraf PuppetDB Performance] with v2' do
          is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Performance').with(
            grafana_url: 'http://localhost:3000',
            grafana_user: 'admin',
            grafana_password: 'puppetlabs',
            require: 'Grafana_datasource[influxdb_telegraf]',
            content: %r{"value_FiveMinuteRate"},
          )
        end

        it 'should contain Grafana_dashboard[Telegraf PuppetDB Workload] with v2' do
          is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Workload').with(
            grafana_url: 'http://localhost:3000',
            grafana_user: 'admin',
            grafana_password: 'puppetlabs',
            require: 'Grafana_datasource[influxdb_telegraf]',
            content: %r{"value_999thPercentile"},
          )
        end
      end

      context 'when PuppetDB is remote on a newer version of Puppet' do
        let(:pre_condition) do
          <<-PRE_COND
            function puppet_metrics_dashboard::puppetdb_no_remote_metrics() { true }
            class {'puppet_metrics_dashboard':
              add_dashboard_examples => false,
              influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
              grafana_password       => 'puppetlabs',
              puppetdb_list          => ['remotesys'],
            }
          PRE_COND
        end

        it 'should contain Grafana_dashboard[Telegraf PuppetDB Performance] with v2' do
          is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Performance').with(
            grafana_url: 'http://localhost:3000',
            grafana_user: 'admin',
            grafana_password: 'puppetlabs',
            require: 'Grafana_datasource[influxdb_telegraf]',
            content: %r{"value_FiveMinuteRate"},
          )
        end

        it 'should contain Grafana_dashboard[Telegraf PuppetDB Workload] with v2' do
          is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Workload').with(
            grafana_url: 'http://localhost:3000',
            grafana_user: 'admin',
            grafana_password: 'puppetlabs',
            require: 'Grafana_datasource[influxdb_telegraf]',
            content: %r{"value_999thPercentile"},
          )
        end
      end
      # rubocop:enable RSpec/ExampleWording
    end
  end
end
