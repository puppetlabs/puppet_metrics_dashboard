require 'spec_helper_acceptance'

describe 'pe_metrics_dashboard class' do
  context 'default parameters' do
    it 'installs grafana and influxdb' do
      pp = <<-MANIFEST
    		class {'pe_metrics_dashboard':
          grafana_version => '4.6.1',
          grafana_http_port => 3000,
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
  end
end
