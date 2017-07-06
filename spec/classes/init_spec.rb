require 'spec_helper'
describe 'pe_metrics_dashboard' do
  context 'with default values for all parameters' do
    it { should contain_class('pe_metrics_dashboard') }
  end
end
