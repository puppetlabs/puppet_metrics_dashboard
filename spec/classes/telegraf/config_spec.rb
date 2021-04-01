require 'spec_helper'

describe 'puppet_metrics_dashboard::telegraf::config' do
  on_supported_os.each do |os, facts|
    context "with facter #{RSpec.configuration.default_facter_version} on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(pe_server_version: '2019.5', puppet_server: 'testhost.example.com')
      end

      let(:trusted_facts) { { 'certname' => 'testhost.example.com' } }

      context 'with defaults, run on master' do
        let(:facts) do
          super().merge('puppet_metrics_dashboard' => { 'versions' => { 'puppetdb' => '1.2.3' } })
        end
        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_last_file_sync_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_postgres_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_command-parse-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_discarded_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_fatal_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_message-persistence-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_processed_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_processing-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_retried_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_retry-counts_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_global_seen_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_catalog_retried_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_catalog_retry-counts_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_facts_retried_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_replace_facts_retry-counts_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_store_report_retried_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_mq_store_reports_retry-counts_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_ActiveConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_IdleConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_PendingConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_TotalConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_Usage_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBReadPool_pool_Wait_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_ActiveConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_IdleConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_PendingConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_TotalConnections_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_Usage_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_PDBWritePool_pool_Wait_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_add-edges_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_add-resources_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash-match-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_catalog-hash-miss-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-catalogs-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-environments-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-fact-paths_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-params-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-report-statuses_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_gc-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_new-catalogs_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_new-catalog-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_replace-catalog-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_replace-facts-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_resource-hashes_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/puppetdb_storage_store-report-time_localhost.conf') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_cert.pem') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_key.pem') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.conf') }
        it { is_expected.not_to contain_tidy('clean /etc/telegraf/telegraf.d') }
      end

      context 'with defaults, not run on master' do
        let(:facts) do
          super().merge('puppet_server' => 'master.example.com')
        end

        let(:pre_condition) do
          <<-PRE_COND
            include puppet_metrics_dashboard
          PRE_COND
        end

        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_last_file_sync_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.d/pe_postgres_testhost.example.com.conf') }
        it { is_expected.not_to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_localhost.conf') }
        it { is_expected.not_to contain_file('/etc/telegraf/telegraf.d/puppetdb_command_queue_testhost.example.com.conf') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_cert.pem') }
        it { is_expected.to contain_file('/etc/telegraf/testhost.example.com_key.pem') }
        it { is_expected.to contain_file('/etc/telegraf/telegraf.conf') }
        it { is_expected.not_to contain_tidy('clean /etc/telegraf/telegraf.d') }
      end

      context 'with tidy_telegraf_configs set to true' do
        let(:pre_condition) do
          <<-PRE_COND
            class { 'puppet_metrics_dashboard':
              tidy_telegraf_configs => true
            }
          PRE_COND
        end

        it { is_expected.to contain_tidy('clean /etc/telegraf/telegraf.d') }
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
            .with_content(%r{\s*timeout\s*=\s*\"123s\"})
        end
      end
    end
  end
end
