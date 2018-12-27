require 'spec_helper'
describe 'puppet_metrics_dashboard::grafana' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          pe_server_version: '2017.2',
          puppet_sslpaths: {
            certdir: {
              path: '/etc/puppetlabs/puppet/ssl/certs',
            },
            privatekeydir: {
              path: '/etc/puppetlabs/puppet/ssl/private_keys',
            },
          },
        )
      end

      context 'with dashboard ssl' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              use_dashboard_ssl => true,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
