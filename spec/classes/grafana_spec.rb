require 'spec_helper'

describe 'puppet_metrics_dashboard::grafana' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
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
            .with_cfg('server' => { 'http_port' => 3000 }, 'security' => { 'admin_user' => 'admin', 'admin_password' => 'admin' })

          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_class('grafana')
              .with_require('Service[influxd]')
          when 'RedHat'
            is_expected.to contain_class('grafana')
              .with_require('Service[influxdb]')
          end
        end
        # rubocop:enable RSpec/ExampleWording
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
            .with_cfg(
              'server' => {
                'http_port' => 3000,
                'protocol'  => 'https',
                'cert_file' => '/etc/grafana/testhost.example.com_cert.pem',
                'cert_key'  => '/etc/grafana/testhost.example.com_key.pem',
              },
              'security' => {
                'admin_user'     => 'admin',
                'admin_password' => 'admin',
              },
            )
        end
        # rubocop:enable RSpec/ExampleWording
      end

      context 'with ldap enabled' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              enable_ldap_auth => true,
            }
          PRE_COND
        end

        it 'contains Class[grafana] with an ldap config' do
          is_expected.to contain_class('grafana')
            .with_cfg(
              'auth.ldap' => {
                'enabled' => true,
                'config_file' => '/etc/grafana/ldap.toml',
                'allow_sign_up'  => 'true',
              },
              'security' => {
                'admin_user'     => 'admin',
                'admin_password' => 'admin',
              },
              'server' => {
                'http_port' => 3000,
              },
            )
        end
      end
    end
  end
end
