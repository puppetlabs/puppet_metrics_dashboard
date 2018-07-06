require 'spec_helper'
describe 'puppet_metrics_dashboard' do
  context 'with default values for all parameters' do
    let(:facts) do
      {
        osfamily: 'RedHat',
        os: {
          family: 'RedHat',
          release: {
            major: '7',
          },
        },
        operatingsystem: 'RedHat',
        pe_server_version: '2017.2',
      }
    end

    it { is_expected.to contain_class('puppet_metrics_dashboard') }
  end
end
