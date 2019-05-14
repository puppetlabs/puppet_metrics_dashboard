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
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_cert.pem') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_key.pem') }
      end

      context 'when master_list includes entries with port numbers' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              master_list        => ['some-host.test',
                                     ['some-other.host.test', 9140]],
              puppetdb_list      => [],
              postgres_host_list => [],
            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-host\.test:8140})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-other\.host\.test:9140})
        end
      end

      context 'when puppetdb_list includes entries with port numbers' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              master_list        => [],
              puppetdb_list      => ['some-host.test',
                                     ['some-other.host.test', 8100]],
              postgres_host_list => [],
            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-host\.test:8081})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-other\.host\.test:8100})
        end
      end

      context 'when postgres_host_list includes entries with port numbers' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              master_list        => [],
              puppetdb_list      => [],
              postgres_host_list => ['some-host.test',
                                     ['some-other.host.test', 9000]],

            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-host\.test:5432})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{some-other\.host\.test:9000})
        end
      end
      context 'when http_response_timeout is set' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              http_response_timeout => 123,
            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{\s*timeout\s*=\s*\'123s\'})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf')\
            .with_content(%r{\s*response_timeout\s*=\s*\'123s\'})
        end
      end
    end
  end
end
