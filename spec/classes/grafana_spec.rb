require 'spec_helper'

describe 'puppet_metrics_dashboard::grafana' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "with facter 3.7 on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

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

      context 'with defaults' do
        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        # rubocop:disable RSpec/ExampleWording
        it 'should not contain ssl cert files' do
          is_expected.not_to contain_file('/etc/grafana/testhost.example.com_cert.pem')
          is_expected.not_to contain_file('/etc/grafana/testhost.example.com_key.pem')
        end

        it 'should contain Class[grafana] with an http config' do
          is_expected.to contain_class('grafana')
            .with_install_method('repo')
            .with_manage_package_repo(false)
            .with_version('5.1.4')
            .with_cfg('server' => { 'http_port' => 3000 })
            .with_require('Http_conn_validator[influxdb-conn-validator]')
        end

        it 'should contain Http_conn_validator[grafana-conn-validator]' do
          is_expected.to contain_http_conn_validator('grafana-conn-validator')
            .with_test_url('/public/img/grafana_icon.svg')
        end
        # rubocop:enable RSpec/ExampleWording

        it { is_expected.to contain_exec('update Grafana admin password') }
      end

      context 'with ssl enabled' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              use_dashboard_ssl => true,
            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/grafana/testhost.example.com_cert.pem')
        end

        it do
          is_expected.to contain_file('/etc/grafana/testhost.example.com_key.pem')
        end

        # rubocop:disable RSpec/ExampleWording
        it 'should contain Class[grafana] with an https config' do
          is_expected.to contain_class('grafana')
            .with_cfg('server' => {
                        'http_port' => 3000,
                        'protocol'  => 'https',
                        'cert_file' => '/etc/grafana/testhost.example.com_cert.pem',
                        'cert_key'  => '/etc/grafana/testhost.example.com_key.pem',
                      })
        end
        # rubocop:enable RSpec/ExampleWording
      end
    end
  end
end
