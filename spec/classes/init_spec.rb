require 'spec_helper'
describe 'puppet_metrics_dashboard' do
  on_supported_os(facterversion: '3.7').each do |os, facts|
    context "with facter 3.7 on #{os}" do
      let(:node) do
        'testhost.example.com'
      end

      let(:facts) do
        facts.merge(
          pe_server_version: '2017.2',
          puppet_sslpaths: {
            certdir: {
              path: '/etc/puppetlabs/puppet/ssl/certs',
            },
            privatekeydir: {
              path: '/etc/puppetlabs/puppet/ssl/private_keys',
            },
          },
        )
      end

      context 'with default values for all parameters' do
        it { is_expected.to contain_class('puppet_metrics_dashboard') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::params') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::repos') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::install') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::config') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::service') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::post_start_configs') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::grafana') }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::dashboards') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::telegraf') }

        # verify the defualts have not changed
        # rubocop:disable RSpec/ExampleWording
        it 'should have all the expected default vaulues for parameters' do
          is_expected.to contain_class('puppet_metrics_dashboard')
            .with_add_dashboard_examples(false)
            .with_manage_repos(true)
            .with_use_dashboard_ssl(false)
            .with_dashboard_cert_file('/etc/grafana/testhost.example.com_cert.pem')
            .with_dashboard_cert_key('/etc/grafana/testhost.example.com_key.pem')
            .with_overwrite_dashboards(true)
            .with_overwrite_dashboards_file('/opt/puppetlabs/puppet/cache/state/overwrite_dashboards_disabled')
            .with_influxdb_database_name(['telegraf'])
            .with_grafana_version('5.1.4')
            .with_grafana_http_port(3000)
            .with_influx_db_password('puppet')
            .with_grafana_password('admin')
            .with_enable_kapacitor(false)
            .with_enable_chronograf(false)
            .with_enable_telegraf(true)
            .with_configure_telegraf(true)
            .with_consume_graphite(false)
            .with_master_list(['testhost.example.com'])
            .with_puppetdb_list(['testhost.example.com'])
            .with_influxdb_urls("['http://localhost:8086']")
            .with_telegraf_db_name('telegraf')
            .with_telegraf_agent_interval(5)
            .with_http_response_timeout(5)

          case facts[:os]['family']
          when 'Debian'
            is_expected.to contain_class('puppet_metrics_dashboard')
              .with_influx_db_service_name('influxd')
          when 'RedHat'
            is_expected.to contain_class('puppet_metrics_dashboard')
              .with_influx_db_service_name('influxdb')
          end
        end
        # rubocop:enable RSpec/ExampleWording
      end

      context 'with example dashboards' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              add_dashboard_examples => true,
              influxdb_database_name => ['puppet_metrics','telegraf','graphite'],
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::graphite') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::puppet_metrics') }
        it { is_expected.to contain_class('puppet_metrics_dashboard::dashboards::telegraf') }
      end

      context 'with manage_repos => false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
                manage_repos => false,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::repos') }
      end

      context 'with dashboard ssl' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              use_dashboard_ssl => true,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with overwrite_dashboards => false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              overwrite_dashboards => false,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with alternate overwrite_dashboards_file path' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              overwrite_dashboards_file => '/tmp/overwrite_dashboards_file',
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with alternate influx_db_service_name name' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              influx_db_service_name => 'custom_influxdb_service',
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
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

        it { is_expected.to compile.with_all_deps }
      end

      context 'with different Grafana settings' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              grafana_version   => '9999.9999.9999',
              grafana_http_port => 3333,
              grafana_password  => 'pa55w0rd',
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with alternate influx_db_password password' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              influx_db_password => 'pa55w0rd',
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
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

        it { is_expected.to compile.with_all_deps }
      end

      context 'with enable_telegraf => false and configure_telegraf => false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              enable_telegraf  => false,
              configure_telegraf => false,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_class('puppet_metrics_dashboard::telegraf') }
      end

      context 'with enable_telegraf => false and configure_telegraf => true' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              enable_telegraf  => false,
              configure_telegraf => true,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('puppet_metrics_dashboard::telegraf') }
      end

      context 'with configure_telegraf => false' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              configure_telegraf => false,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with consume_graphite => true' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              consume_graphite => true,
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'With an empty array of masters' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              master_list => [],
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with remote master and puppetdb' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              master_list   => [
                'master.example.com',
                'compiler1.example.com',
                'compiler2.example.com',
              ],
              puppetdb_list => ['pe.example.com'],
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      # TODO: make sure this does more than configure Telegraf
      context 'with remote InfluxDB' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              influxdb_urls => "['http://influxdb.example.com:8086']"
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
        # it should not instlal Influx or mess with its service
      end

      context 'with alternate telegraf_db_name' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              telegraf_db_name => 'metrics',
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with longer intervals for Telegraf' do
        let(:pre_condition) do
          <<-PRE_COND
            class {'puppet_metrics_dashboard':
              telegraf_agent_interval => 30,
              http_response_timeout   => 30
            }
          PRE_COND
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
