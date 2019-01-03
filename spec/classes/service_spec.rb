require 'spec_helper'

describe 'puppet_metrics_dashboard::service' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "with facter 3.7 on #{os}" do
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

        case facts[:os]['family']
        when 'RedHat'
          it do
            is_expected.to contain_service('influxdb')
              .with_ensure('running')
              .with_enable(true)

            is_expected.to contain_http_conn_validator('influxdb-conn-validator')
              .with_test_url('/ping?verbose=true')
              .with_require('Service[influxdb]')
          end
        when 'Debian'
          it do
            is_expected.to contain_service('influxd')
              .with_ensure('running')
              .with_enable(true)

            is_expected.to contain_http_conn_validator('influxdb-conn-validator')
              .with_test_url('/ping?verbose=true')
              .with_require('Service[influxd]')
          end
        end
      end

      context 'with alternate influx_db_service_name name' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              influx_db_service_name => 'custom_influxdb_service',
            }
          PRE_COND
        end

        it { is_expected.to contain_service('custom_influxdb_service') }
      end

      context 'with kapacitor and chronograf enabled' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              enable_kapacitor  => true,
              enable_chronograf => true,
            }
          PRE_COND
        end

        it do
          is_expected.to contain_service('chronograf')
            .with_ensure('running')
            .with_enable(true)
        end

        it do
          is_expected.to contain_service('kapacitor')
            .with_ensure('running')
            .with_enable(true)
        end
      end
    end
  end
end
