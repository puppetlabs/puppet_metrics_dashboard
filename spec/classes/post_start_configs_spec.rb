require 'spec_helper'

describe 'puppet_metrics_dashboard::post_start_configs' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      context 'with defaults' do
        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        # rubocop:disable RSpec/ExampleWording
        it 'should contain Exec[wait for influxdb]' do
          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_exec('wait for influxdb')
              .with_command('/bin/sleep 10')
              .with_unless('/usr/bin/influx -execute "SHOW DATABASES"')
              .with_require('Service[influxd]')
          when 'RedHat'
            is_expected.to contain_exec('wait for influxdb')
              .with_command('/bin/sleep 10')
              .with_unless('/usr/bin/influx -execute "SHOW DATABASES"')
              .with_require('Service[influxdb]')
          end
        end

        it 'should contain Exec[create influxdb admin user]' do
          is_expected.to contain_exec('create influxdb admin user')
            .with_command("/usr/bin/influx -execute \"CREATE USER admin WITH PASSWORD 'puppet' WITH ALL PRIVILEGES\"")
            .with_unless("/usr/bin/influx -username admin -password puppet -execute 'show users' | grep 'admin true'")
        end

        it 'should contain Exec[create influxdb puppet_metrics database telegraf]' do
          is_expected.to contain_exec('create influxdb puppet_metrics database telegraf')
            .with(
              'command' => '/usr/bin/influx -username admin -password puppet -execute "create database telegraf"',
              'unless' => "/usr/bin/influx -username admin -password puppet -execute 'show databases' | grep telegraf",
            )
        end

        it 'should contain Grafana_datasource[influxdb_telegraf]' do
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
        # rubocop:enable RSpec/ExampleWording
      end

      context 'with all three influxdb_database_name values' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              influxdb_database_name => [
                'puppet_metrics',
                'telegraf',
                'graphite'
              ],
            }
          PRE_COND
        end

        it do
          is_expected.to contain_exec('create influxdb puppet_metrics database puppet_metrics')
        end

        it do
          is_expected.to contain_exec('create influxdb puppet_metrics database telegraf')
        end

        it do
          is_expected.to contain_exec('create influxdb puppet_metrics database graphite')
        end

        it do
          is_expected.to contain_grafana_datasource('influxdb_puppet_metrics')
        end

        it do
          is_expected.to contain_grafana_datasource('influxdb_telegraf')
        end

        it do
          is_expected.to contain_grafana_datasource('influxdb_graphite')
        end
      end
    end
  end
end
