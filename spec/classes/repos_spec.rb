require 'spec_helper'
describe 'puppet_metrics_dashboard::repos' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      context 'with manage_repo => true' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              manage_repos => true,
            }
          PRE_COND
        end

        # rubocop:disable RSpec/ExampleWording
        # rubocop:disable RSpec/RepeatedDescription
        # rubocop:disable RSpec/RepeatedExample
        case facts[:os]['name']
        when 'RedHat'
          it 'should contain the yum repo for InfluxDB' do
            is_expected.to contain_yumrepo('influxdb')
              .with(
                'ensure' => 'present',
                'descr' => 'influxdb-repository',
                'enabled' => '1',
                'gpgcheck' => '1',
                'baseurl' => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
                'gpgkey' => 'https://repos.influxdata.com/influxdb.key',
              )
          end

          it 'should contain the yum repo for Grafana' do
            is_expected.to contain_yumrepo('grafana-repo')
              .with(
                'ensure' => 'present',
                'baseurl' => 'https://packages.grafana.com/oss/rpm',
                'descr' => 'grafana-repository',
                'enabled' => '1',
                'repo_gpgcheck' => '1',
                'gpgcheck' => '1',
                'gpgkey' => 'https://packages.grafana.com/gpg.key',
                'sslverify' => '1',
                'sslcacert' => '/etc/pki/tls/certs/ca-bundle.crt',
              )
          end
        when 'Debian'
          it 'should contain the apt repo for InfluxDB' do
            is_expected.to contain_apt__source('influxdb')
              .with(
                'location' => 'https://repos.influxdata.com/debian',
                'release' => facts[:os]['distro']['codename'],
                'repos' => 'stable',
              )
          end

          it 'should contain the yum repo for Grafana' do
            is_expected.to contain_apt__source('grafana')
              .with(
                'location' => 'https://packages.grafana.com/oss/deb',
                'release' => 'stable',
                'repos' => 'main',
              )
          end
        when 'Ubuntu'
          it 'should contain the apt repo for InfluxDB' do
            is_expected.to contain_apt__source('influxdb')
              .with(
                'location' => 'https://repos.influxdata.com/ubuntu',
                'release' => facts[:os]['distro']['codename'],
                'repos' => 'stable',
              )
          end

          it 'should contain the yum repo for Grafana' do
            is_expected.to contain_apt__source('grafana')
              .with(
                'location' => 'https://packages.grafana.com/oss/deb',
                'release' => 'stable',
                'repos' => 'main',
              )
          end
        end
        # rubocop:enable RSpec/ExampleWording
        # rubocop:enable RSpec/RepeatedDescription
        # rubocop:enable RSpec/RepeatedExample
      end

      context 'with manage_repo => false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              manage_repos => false,
            }
          PRE_COND
        end

        case facts[:os]['family']
        when 'RedHat'
          it do
            is_expected.not_to contain_yumrepo('influxdb')
          end

          it do
            is_expected.not_to contain_yumrepo('grafana-repo')
          end
        when 'Debian'
          it do
            is_expected.not_to contain_apt__source('influxdb')
          end

          it do
            is_expected.not_to contain_apt__source('grafana')
          end
        end
      end
    end
  end
end
