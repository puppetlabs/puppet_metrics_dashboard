require 'spec_helper'

describe 'puppet_metrics_dashboard::install' do
  context 'Default Configuration' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        os: {
          family: 'RedHat',
        },
        operatingsystem: 'RedHat',
        pe_server_version: '2017.2',
      }
    end

    let(:params) do
      {
        add_dashboard_examples: false,
        influx_db_service_name: 'influxdb',
        influxdb_database_name: ['pe_metrics'],
        grafana_version: '4.6.1',
        grafana_http_port: 3000,
        influx_db_password: 'puppet',
        grafana_password: 'admin',
        use_dashboard_ssl: false,

      }
    end

    it do
      is_expected.to contain_package('influxdb')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.to contain_service('influxdb')
        .with(
          'ensure' => 'running',
          'require' => 'Package[influxdb]',
        )
    end

    it do
      is_expected.to contain_class('grafana')
        .with(
          'install_method' => 'repo',
          'manage_package_repo' => false,
          'version' => '4.6.1',
          'cfg' => { 'server' => { 'http_port' => 3000 } },
          'require' => 'Service[influxdb]',
        )
    end

    it do
      is_expected.not_to contain_package('kapacitor')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.not_to contain_service('kapacitor')
        .with(
          'ensure' => 'running',
          'enable' => true,
        )
    end

    it do
      is_expected.to contain_package('telegraf')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.to contain_service('telegraf')
        .with(
          'ensure' => 'running',
          'enable' => true,
        )
    end

    it do
      is_expected.not_to contain_package('chronograf')
        .with(
          'ensure' => 'present',
        )
    end

    it do
      is_expected.not_to contain_service('chronograf')
        .with(
          'ensure' => 'running',
          'enable' => true,
        )
    end

    it do
      is_expected.to contain_exec('wait for influxdb')
        .with(
          'command' => '/bin/sleep 10',
          'unless' => '/usr/bin/influx -execute "SHOW DATABASES"',
          'require' => 'Service[influxdb]',
        )
    end

    it do
      is_expected.to contain_exec('create influxdb admin user')
        .with(
          'command' => "/usr/bin/influx -execute \"CREATE USER admin WITH PASSWORD 'puppet' WITH ALL PRIVILEGES\"",
          'unless' => "/usr/bin/influx -username admin -password puppet -execute 'show users' | grep 'admin true'",
        )
    end

    it do
      is_expected.to contain_exec('create influxdb pe_metrics database pe_metrics')
        .with(
          'command' => '/usr/bin/influx -username admin -password puppet -execute "create database pe_metrics"',
          'unless' => "/usr/bin/influx -username admin -password puppet -execute 'show databases' | grep pe_metrics",
        )
    end

    it do
      is_expected.to contain_grafana_datasource('influxdb_pe_metrics')
        .with(
          'grafana_url' => 'http://localhost:3000',
          'type' => 'influxdb',
          'database' => 'pe_metrics',
          'url' => 'http://localhost:8086',
          'access_mode' => 'proxy',
          'is_default' => false,
          'user' => 'admin',
          'password' => 'puppet',
          'grafana_user' => 'admin',
          'grafana_password' => 'admin',
          'require' => ['Service[grafana-server]', 'Exec[create influxdb pe_metrics database pe_metrics]'],
        )
    end
  end

  context 'With dashboard exmples on Ubuntu' do
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
        add_dashboard_examples: true,
        grafana_password: 'admin',
        grafana_http_port: 3000,
        use_dashboard_ssl: false,
      }
    end

    it do
      is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Performance')
        .with(
          'grafana_url' => 'http://localhost:3000',
          'grafana_user' => 'admin',
          'grafana_password' => 'admin',
          'require' => 'Grafana_datasource[influxdb_telegraf]',
        )
    end

    it do
      is_expected.to contain_grafana_dashboard('Telegraf PuppetDB Workload')
        .with(
          'grafana_url' => 'http://localhost:3000',
          'grafana_user' => 'admin',
          'grafana_password' => 'admin',
          'require' => 'Grafana_datasource[influxdb_telegraf]',
        )
    end

    it do
      is_expected.to contain_grafana_dashboard('Telegraf Puppetserver Performance')
        .with(
          'grafana_url' => 'http://localhost:3000',
          'grafana_user' => 'admin',
          'grafana_password' => 'admin',
          'require' => 'Grafana_datasource[influxdb_telegraf]',
        )
    end
  end
end
