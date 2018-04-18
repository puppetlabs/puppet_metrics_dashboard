require 'spec_helper'
describe 'pe_metrics_dashboard' do
  context 'with default values for all parameters' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        os: {
          family: 'RedHat',
        },
        operatingsystem: 'RedHat',
        pe_server_version: '2017.2',
      }
    end

    it { is_expected.to contain_class('pe_metrics_dashboard') }
  end
end
