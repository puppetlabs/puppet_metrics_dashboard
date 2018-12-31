require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf::config' do
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

        it { is_expected.to contain_ini_setting('telegraf agent - interval').with_value("'5s'") }
        it { is_expected.to contain_ini_setting('telegraf agent - round_interval').with_value(true) }
        it { is_expected.to contain_ini_setting('telegraf agent - metric_batch_size').with_value(1000) }
        it { is_expected.to contain_ini_setting('telegraf agent - metric_buffer_limit').with_value(10_000) }
        it { is_expected.to contain_ini_setting('telegraf agent - collection_jitter').with_value("'0s'") }
        it { is_expected.to contain_ini_setting('telegraf agent - flush_interval').with_value("'10s'") }
        it { is_expected.to contain_ini_setting('telegraf agent - flush_jitter').with_value("'0s'") }
        it { is_expected.to contain_ini_setting('telegraf agent - precision').with_value("''") }
        it { is_expected.to contain_ini_setting('telegraf agent - debug').with_value(false) }
        it { is_expected.to contain_ini_setting('telegraf agent - quiet').with_value(false) }
        it { is_expected.to contain_ini_setting('telegraf agent - logfile').with_value("'/var/log/telegraf/telegraf.log'") }
        it { is_expected.to contain_ini_setting('telegraf agent - hostname').with_value("''") }
        it { is_expected.to contain_ini_setting('telegraf agent - omit_hostname').with_value(false) }
        it { is_expected.to contain_ini_setting('telegraf outputs.influxdb - urls').with_value("['http://localhost:8086']") }
        it { is_expected.to contain_ini_setting('telegraf outputs.influxdb - database').with_value("'telegraf'") }
        it { is_expected.to contain_ini_setting('telegraf outputs.influxdb - retention_policy').with_value("''") }
        it { is_expected.to contain_ini_setting('telegraf outputs.influxdb - write_consistency').with_value("'any'") }
        it { is_expected.to contain_ini_setting('telegraf outputs.influxdb - timeout').with_value("'5s'") }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf') }
      end
    end
  end
end
