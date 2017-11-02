require 'spec_helper_acceptance'

describe 'pe_metrics_dashboard::install class' do
  context 'default parameters' do
    it 'should install grafana and influxdb' do
      pp = <<-EOS
    		class {'pe_metrics_dashboard::install':
          grafana_version => '4.6.1',
          grafana_http_port => 3000,
        }
        EOS

      # Run it twice and test for idempotency
      expect(apply_manifest(pp).exit_code).to_not eq(1)
      expect(apply_manifest(pp).exit_code).to eq(0)
    end
    # Grafana should be running
 #   describe service('grafana-server') do
 #     it { should be_running }
 #   end
    describe port('3000') do
      it { should be_listening }
    end

    # Influxdb should be listening on port 8086 by default
    describe port('8086') do
      it { should be_listening }
    end
  end
end
