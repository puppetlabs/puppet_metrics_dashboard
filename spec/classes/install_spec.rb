require 'spec_helper'

describe 'puppet_metrics_dashboard::install' do
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

        case facts[:os]['family']
        when 'RedHat', 'Debian'
          it do
            is_expected.to contain_package('influxdb')
              .with_ensure('present')
          end

          it do
            is_expected.to contain_package('kapacitor')
              .with_ensure('absent')
          end

          it do
            is_expected.to contain_package('chronograf')
              .with_ensure('absent')
          end
        end
      end

      case facts[:os]['family']
      when 'RedHat', 'Debian'
        context 'with Kapacitor and Chronograf enabled' do
          let(:pre_condition) do
            <<-PRE_COND
              class {'puppet_metrics_dashboard':
                enable_kapacitor  => true,
                enable_chronograf => true,
              }
            PRE_COND
          end

          it do
            is_expected.to contain_package('influxdb')
              .with_ensure('present')
          end

          it do
            is_expected.to contain_package('kapacitor')
              .with_ensure('present')
          end

          it do
            is_expected.to contain_package('chronograf')
              .with_ensure('present')
          end
        end
      end
    end
  end
end
