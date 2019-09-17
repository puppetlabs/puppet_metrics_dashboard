require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf::config' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(pe_server_version: '2019.1')
      end

      context 'with defaults' do
        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_last_file_sync_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_postgres_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_command-parse-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_discarded_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_fatal_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_message-persistence-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_processed_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_processing-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_retried_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_retry-counts_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_seen_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_catalog_retried_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_catalog_retry-counts_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_facts_retried_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_facts_retry-counts_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_store_report_retried_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_store_reports_retry-counts_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_ActiveConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_IdleConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_PendingConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_TotalConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_Usage_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_Wait_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_ActiveConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_IdleConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_PendingConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_TotalConnections_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_Usage_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_Wait_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_add-edges_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_add-resources_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash-match-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash-miss-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-catalogs-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-environments-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-fact-paths_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-params-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-report-statuses_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_new-catalogs_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_new-catalog-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_replace-catalog-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_replace-facts-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_resource-hashes_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_store-report-time_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_cert.pem') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_key.pem') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.conf') }
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
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetserver_metrics_some-host.test.conf')\
            .with_content(%r{some-host\.test})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetserver_metrics_some-other.host.test.conf')\
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
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_some-host.test.conf')\
            .with_content(%r{some-host\.test})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_some-other.host.test.conf')\
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
          is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_postgres_some-host.test.conf')\
            .with_content(%r{some-host\.test})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_postgres_some-other.host.test.conf')\
            .with_content(%r{some-other\.host\.test:9000})
        end
      end
      context 'when http_response_timeout is set' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              http_response_timeout => '123s',
            }
          PRE_COND
        end

        it do
          is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_last_file_sync_testhost.example.com.conf')\
            .with_content(%r{\s*timeout\s*=\s*\"123s\"})
          is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetserver_metrics_testhost.example.com.conf')\
            .with_content(%r{\s*response_timeout\s*=\s*\"123s\"})
        end
      end
    end
  end
end
