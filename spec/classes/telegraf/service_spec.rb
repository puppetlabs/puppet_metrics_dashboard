require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf::service' do
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

        it { is_expected.to contain_service('telegraf').with_ensure('running') }
      end
    end
  end
end
