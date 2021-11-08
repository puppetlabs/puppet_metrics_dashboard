require 'spec_helper'

describe 'puppet_metrics_dashboard::profile::dbcompiler::install' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(
          networking: {
            fqdn: 'testhost.example.com',
          },
        )
      end

      let :params do
        {
          'timeout' => '5s',
          'puppetdb_metrics' => [{ 'name' => 'metric_name', 'url' => 'metrics_url' }],
          'influxdb_urls' => ['http://influx.example.com'],
          'tidy_telegraf_configs' => false,
        }
      end

      context 'with default and required params passed in' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('telegraf') }
        it 'contains the Compiler Profile' do
          is_expected.to contain_puppet_metrics_dashboard__profile__compiler('testhost.example.com').with(
            timeout: '5s',
            compiler: 'testhost.example.com',
            port: 8140,
            interval: '5s',
          )
        end
        it 'contains the Puppetdb Profile' do
          is_expected.to contain_puppet_metrics_dashboard__profile__puppetdb('testhost.example.com').with(
            timeout: '5s',
            puppetdb_host: 'localhost',
            puppetdb_metrics: [{ 'name' => 'metric_name', 'url' => 'metrics_url' }],
            port: 8081,
            interval: '5s',
            enable_client_cert: true,
          )
        end
        it 'does not contain a tidy resource' do
          is_expected.not_to contain_tidy('clean /etc/telegraf/telegraf.d')
        end
      end

      context 'with tidy_telegraf_configs set true' do
        let :params do
          super().merge('tidy_telegraf_configs' => true)
        end

        it 'contains a tidy resource' do
          is_expected.to contain_tidy('clean /etc/telegraf/telegraf.d')
        end
      end

      context 'with manage_repo set false' do
        let :params do
          super().merge('manage_repo' => false)
        end

        it { is_expected.to contain_class('telegraf').with('manage_repo' => false) }
      end
    end
  end
end
