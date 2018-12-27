require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(pe_server_version: '2017.2')
      end

      let(:pre_condition) do
        <<-PRE_COND
          class {'puppet_metrics_dashboard':
            influxdb_database_name => ['telegraf'],
            configure_telegraf  => true,
            enable_telegraf     => true,
          }
        PRE_COND
      end

      case facts[:os]['family']
      when 'Debian'
        it do
          is_expected.to contain_service('telegraf').with(
            ensure: 'running',
            enable: true,
            require: ['Package[telegraf]', 'Service[influxd]'],
          )
        end
      when 'RedHat'
        it do
          is_expected.to contain_service('telegraf').with(
            ensure: 'running',
            enable: true,
            require: ['Package[telegraf]', 'Service[influxdb]'],
          )
        end
      end

      it do
        is_expected.to contain_package('telegraf').with(
          ensure: 'present',
          require: 'Class[Puppet_metrics_dashboard::Repos]',
        )
      end

      it do
        is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf').with(
          ensure: 'file',
          owner: '0',
          group: '0',
          notify: 'Service[telegraf]',
          require: 'Package[telegraf]',
        )
      end
    end
  end
end
