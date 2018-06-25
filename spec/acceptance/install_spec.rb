require 'spec_helper_acceptance'

describe 'puppet_metrics_dashboard::install class' do
  context 'archive metrics' do
    it 'installs and configures influxdb' do
      pp = <<-MANIFEST
        class {'puppet_metrics_dashboard::install':
            grafana_http_port => 3000,
            influxdb_database_name => ['pe_metrics'],
            configure_telegraf => false,
            enable_telegraf => false,
            add_dashboard_examples => true,
        }
        MANIFEST

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).not_to eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end
    describe port('3000') do
      it { is_expected.to be_listening }
    end

    # Influxdb should be listening on port 8086 by default
    describe port('8086') do
      it { is_expected.to be_listening }
    end

    describe 'applications accept api calls' do
      it 'influxdb accepts data' do
        curlquery = <<-QUERY
          curl -i -X POST 'http://127.0.0.1:8086/write?db=pe_metrics&precision=s&u=admin&p=puppetlabs' \
          --data-binary 'puppetserver.pe-jruby-metrics.num-free-jrubies,server=127-0-0-1 num-free-jrubies=1 1523993402'
          QUERY
        shell(curlquery.to_s) do |r|
          expect(r.exit_code).to eq(0)
          expect(r.stdout).to match(%r{HTTP/1.1 20?.*})
        end
      end

      it 'influxdb answers data queries' do
        curlquery = <<-QUERY
          curl -i -X POST 'http://127.0.0.1:8086/query?db=pe_metrics&u=admin&p=puppetlabs' \
          --data-urlencode 'q=SELECT * FROM "puppetserver.pe-jruby-metrics.num-free-jrubies"'
          QUERY
        shell(curlquery.to_s) do |r|
          expect(r.exit_code).to eq(0)
          expect(r.stdout).to match(%r{puppetserver.pe-jruby-metrics.num-free-jrubies})
        end
      end

      it 'grafana has a data source' do
        curlquery = <<-QUERY
          curl -G http://admin:admin@127.0.0.1:3000/api/datasources/name/influxdb_pe_metrics
          QUERY
        shell(curlquery.to_s) do |r|
          expect(r.exit_code).to eq(0)
          expect(r.stdout).to match(%r{influxdb_pe_metrics})
        end
      end
    end
  end
end
