require 'spec_helper'

describe 'puppet_metrics_dashboard::dashboards::graphite' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      let(:pre_condition) do
        <<-PRE_COND
          class {'puppet_metrics_dashboard':
            add_dashboard_examples => false,
            influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
            grafana_password       => 'puppetlabs',
          }
        PRE_COND
      end

      # rubocop:disable RSpec/ExampleWording
      it 'should contain Grafana_dashboard[Graphite Puppetserver Performance]' do
        is_expected.to contain_grafana_dashboard('Graphite Puppetserver Performance').with(
          grafana_url: 'http://localhost:3000',
          grafana_user: 'admin',
          grafana_password: 'puppetlabs',
          require: 'Grafana_datasource[influxdb_graphite]',
        )
      end
      # rubocop:enable RSpec/ExampleWording
    end
  end
end
