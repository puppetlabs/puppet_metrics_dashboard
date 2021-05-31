require 'spec_helper'
describe 'puppet_metrics_dashboard::profile::master::install' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end
      let(:facts) do
        facts.merge(pe_server_version: '2019.8.6')
      end

      context 'with defaults' do
        let(:pre_condition) do
          <<-PRE_COND
            service { 'pe-puppetserver': ensure => running }
          PRE_COND
        end
        let(:params) { { 'manage_ldap_auth' => true } }

        it do
          is_expected.to contain_package('toml')
            .with_ensure('present')
        end
        it do
          is_expected.to contain_package('toml-rb')
            .with_ensure('present')
        end
      end
    end
  end
end
