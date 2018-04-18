require 'spec_helper'
describe 'pe_metrics_dashboard::repos' do
  context 'on RedHat' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
      }
    end
    let(:params) do
      {
        manage_repos: true,
      }
    end

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
  end

  context 'on RedHat with manage_repo false' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        operatingsystem: 'RedHat',
      }
    end
    let(:params) do
      {
        manage_repos: false,
      }
    end

    it do
      is_expected.not_to contain_yumrepo('influxdb')
    end

    it do
      is_expected.not_to contain_yumrepo('grafana-repo')
    end
  end

  context 'on Ubuntu' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            major: '14',
            full: '14.04.5',
          },
          distro: {
            codename: 'trusty',
          },
        },
        osfamily: 'Debian',
        lsbdistcodename: 'trusty',
        lsbdistid: 'ubuntu',
        lsbdistrelease: '14.04',
        puppetversion: Puppet.version,
        operatingsystem: 'Ubuntu',
        pe_server_version: '2017.2',
      }
    end
    let(:params) do
      {
        manage_repos: true,
      }
    end

    it do
      is_expected.to contain_apt__source('influxdb')
        .with(
          'location' => 'https://repos.influxdata.com/ubuntu',
          'release' => 'trusty',
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

  context 'on Ubuntu with manage_repo false' do
    let(:facts) do
      {
        os: {
          family: 'Debian',
          name: 'Ubuntu',
          release: {
            major: '14',
            full: '14.04.5',
          },
          distro: {
            codename: 'trusty',
          },
        },
        osfamily: 'Debian',
        lsbdistcodename: 'trusty',
        lsbdistid: 'ubuntu',
        lsbdistrelease: '14.04',
        puppetversion: Puppet.version,
        operatingsystem: 'Ubuntu',
        pe_server_version: '2017.2',
      }
    end
    let(:params) do
      {
        manage_repos: false,
      }
    end

    it do
      is_expected.not_to contain_apt__source('influxdb')
    end

    it do
      is_expected.not_to contain_apt__source('grafana')
    end
  end
end
