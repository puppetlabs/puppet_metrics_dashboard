require 'spec_helper'

describe 'puppet_metrics_dashboard::install' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      context 'Default Configuration' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':}
          PRE_COND
        end

        it do
          is_expected.to contain_package('influxdb')
            .with(
              'ensure' => 'present',
            )
        end

        case facts[:os]['family']
        when 'RedHat'
          it do
            is_expected.to contain_service('influxdb')
              .with(
                'ensure' => 'running',
                'require' => 'Package[influxdb]',
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
            is_expected.to contain_class('grafana')
              .with(
                'install_method' => 'repo',
                'manage_package_repo' => false,
                'version' => '5.1.4',
                'cfg' => { 'server' => { 'http_port' => 3000 } },
                'require' => 'Service[influxdb]',
              )
          end
        when 'Debian'
          it do
            is_expected.to contain_service('influxd')
              .with(
                'ensure' => 'running',
                'require' => 'Package[influxdb]',
              )
          end

          it do
            is_expected.to contain_exec('wait for influxdb')
              .with(
                'command' => '/bin/sleep 10',
                'unless' => '/usr/bin/influx -execute "SHOW DATABASES"',
                'require' => 'Service[influxd]',
              )
          end

          it do
            is_expected.to contain_class('grafana')
              .with(
                'install_method' => 'repo',
                'manage_package_repo' => false,
                'version' => '5.1.4',
                'cfg' => { 'server' => { 'http_port' => 3000 } },
                'require' => 'Service[influxd]',
              )
          end
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
          is_expected.to contain_exec('create influxdb admin user')
            .with(
              'command' => "/usr/bin/influx -execute \"CREATE USER admin WITH PASSWORD 'puppet' WITH ALL PRIVILEGES\"",
              'unless' => "/usr/bin/influx -username admin -password puppet -execute 'show users' | grep 'admin true'",
            )
        end

        it do
          is_expected.to contain_exec('create influxdb puppet_metrics database telegraf')
            .with(
              'command' => '/usr/bin/influx -username admin -password puppet -execute "create database telegraf"',
              'unless' => "/usr/bin/influx -username admin -password puppet -execute 'show databases' | grep telegraf",
            )
        end

        it do
          is_expected.to contain_grafana_datasource('influxdb_telegraf')
            .with(
              'grafana_url' => 'http://localhost:3000',
              'type' => 'influxdb',
              'database' => 'telegraf',
              'url' => 'http://localhost:8086',
              'access_mode' => 'proxy',
              'is_default' => false,
              'user' => 'admin',
              'password' => 'puppet',
              'grafana_user' => 'admin',
              'grafana_password' => 'admin',
              'require' => ['Service[grafana-server]', 'Exec[create influxdb puppet_metrics database telegraf]'],
            )
        end
      end
    end
  end
end
