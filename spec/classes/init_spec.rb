require 'spec_helper'
describe 'puppet_metrics_dashboard' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      context 'with default values for all parameters' do
        it { is_expected.to contain_class('puppet_metrics_dashboard') }
      end

      context 'With an empty array of masters' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              master_list => [],
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with example dashboards' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              add_dashboard_examples => true,
              influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::graphite') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::puppet_metrics') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::telegraf') }
      end
    end
  end
end
