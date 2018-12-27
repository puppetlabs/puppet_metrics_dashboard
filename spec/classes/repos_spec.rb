require 'spec_helper'
describe 'puppet_metrics_dashboard::repos' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      let(:pre_condition) do
        <<-PRE_COND
          class {'puppet_metrics_dashboard':
            manage_repos => true,
          }
        PRE_COND
      end

      case facts[:os]['name']
      when 'RedHat'
        it do
          is_expected.to contain_yumrepo('influxdb')
            .with(
              'ensure' => 'present',
              'enabled' => '1',
              'gpgcheck' => '1',
              'baseurl' => 'https://repos.influxdata.com/rhel/$releasever/$basearch/stable',
              'gpgkey' => 'https://repos.influxdata.com/influxdb.key',
            )
        end

        it do
          is_expected.to contain_yumrepo('grafana-repo')
            .with(
              'ensure' => 'present',
              'baseurl' => 'https://packagecloud.io/grafana/stable/el/6/$basearch',
              'descr' => 'grafana-repository',
              'enabled' => '1',
              'repo_gpgcheck' => '1',
              'gpgcheck' => '1',
              'gpgkey' => 'https://packagecloud.io/gpg.key https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
              'sslverify' => '1',
              'sslcacert' => '/etc/pki/tls/certs/ca-bundle.crt',
            )
        end
      when 'Ubuntu'
        it do
          is_expected.to contain_apt__source('influxdb')
            .with(
              'location' => 'https://repos.influxdata.com/ubuntu',
              'release' => 'xenial',
              'repos' => 'stable',
            )
        end

        it do
          is_expected.to contain_apt__source('grafana')
            .with(
              'location' => 'https://packagecloud.io/grafana/stable/debian/',
              'release' => 'jessie',
              'repos' => 'main',
            )
        end
      end

      context 'with manage_repo false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              manage_repos => false,
            }
          PRE_COND
        end

        case facts[:os]['name']
        when 'RedHat'
          it do
            is_expected.not_to contain_yumrepo('influxdb')
          end

          it do
            is_expected.not_to contain_yumrepo('grafana-repo')
          end
        when 'Ubuntu'
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
