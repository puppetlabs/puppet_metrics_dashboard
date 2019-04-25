require 'spec_helper'

describe 'Puppet_metrics_dashboard::HostList' do
  it do
    is_expected.to allow_value(['some-host.test',
                                'some-other.host.test'])
  end
  it do
    is_expected.to allow_value(['some-host.test',
                                ['some-other.host.test', 9140]])
  end

  it do
    is_expected.not_to allow_value([['some-host.test', '9140']])
  end
end
