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

        # rubocop:disable RSpec/RepeatedExample
        case facts[:os]['family']
        when 'RedHat'
          case facts[:os]['release']['major']
          when '7'
            it { is_expected.to contain_file('/usr/lib/tmpfiles.d/grafana.conf').with_content('d /var/run/grafana 0755 grafana grafana') }
            it { is_expected.to contain_exec('Create Systemd Temp Files').with_refreshonly(true) }
          else
            it { is_expected.not_to contain_file('/usr/lib/tmpfiles.d/grafana.conf') }
            it { is_expected.not_to contain_exec('Create Systemd Temp Files') }
          end

          it do
            is_expected.to contain_service('influxdb')
              .with_ensure('running')
              .with_enable(true)
          end
        when 'Debian'
          it { is_expected.not_to contain_file('/usr/lib/tmpfiles.d/grafana.conf') }
          it { is_expected.not_to contain_exec('Create Systemd Temp Files') }

          it do
            is_expected.to contain_service('influxd')
              .with_ensure('running')
              .with_enable(true)
          end
        end
        # rubocop:enable RSpec/RepeatedExample
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
