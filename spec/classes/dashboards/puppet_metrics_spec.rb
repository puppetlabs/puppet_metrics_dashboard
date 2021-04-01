require 'spec_helper'

describe 'puppet_metrics_dashboard::dashboards::puppet_metrics' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      let(:pre_condition) do
        <<-PRE_COND
          class {'puppet_metrics_dashboard':
            add_dashboard_examples => false,
            influxdb_database_name => ['puppet_metrics'],
            grafana_password       => 'puppetlabs',
            enable_telegraf        => false,
            configure_telegraf     => false,
          }
        PRE_COND
      end

      # rubocop:disable RSpec/ExampleWording
      it 'should contain Grafana_dashboard[Archive PuppetDB Performance]' do
        is_expected.to contain_grafana_dashboard('Archive PuppetDB Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive PuppetDB Workload]' do
        is_expected.to contain_grafana_dashboard('Archive PuppetDB Workload').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Puppetserver Performance]' do
        is_expected.to contain_grafana_dashboard('Archive Puppetserver Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive File Sync Metrics]' do
        is_expected.to contain_grafana_dashboard('Archive File Sync Metrics').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Orchestration Services]' do
        is_expected.to contain_grafana_dashboard('Archive Orchestration Services').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Postgres Performance]' do
        is_expected.to contain_grafana_dashboard('Archive Postgres Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Process-System Stats]' do
        is_expected.to contain_grafana_dashboard('Archive Process-System Stats').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Bolt Puma Performance]' do
        is_expected.to contain_grafana_dashboard('Archive Bolt Puma Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Orchestrator JVM Performance]' do
        is_expected.to contain_grafana_dashboard('Archive Orchestrator JVM Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive PuppetDB JVM Performance]' do
        is_expected.to contain_grafana_dashboard('Archive PuppetDB JVM Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end

      it 'should contain Grafana_dashboard[Archive Puppetserver JVM Performance]' do
        is_expected.to contain_grafana_dashboard('Archive Puppetserver JVM Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: ['Grafana_datasource[influxdb_puppet_metrics]', 'Grafana_folder[Deeper Dives]'],
        )
      end
      # rubocop:enable RSpec/ExampleWording
    end
  end
end
