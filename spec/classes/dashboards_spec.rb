require 'spec_helper'

describe 'puppet_metrics_dashboard::dashboards' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "with facter 3.7 on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      context 'with defaults' do
        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        it { is_expected.not_to contain_file('/opt/puppetlabs/puppet/cache/state/overwrite_dashboards_disabled') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards::graphite') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards::puppet_metrics') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards::telegraf') }
      end

      context 'with add_dashboard_examples enabled' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              add_dashboard_examples => true,
            }
          PRE_COND
        end

        it { is_expected.to contain_file('/opt/puppetlabs/puppet/cache/state/overwrite_dashboards_disabled').with_ensure('absent') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards::graphite') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards::puppet_metrics') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::telegraf') }
      end
    end
  end
end
