# frozen_string_literal: true

require 'singleton'
require 'puppetlabs_spec_helper/module_spec_helper'
require 'serverspec'
include PuppetLitmus

class LitmusHelper
  include Singleton
  include PuppetLitmus
end

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    pp = <<-PUPPETCODE
      package{'toml-rb':
        ensure   => installed,
        provider => puppet_gem,
      }
      if $facts['os']['family'] == 'Debian' {
        package{['lsb-release','iproute2','curl']:
          ensure => installed,
        }
      }
    PUPPETCODE
    apply_manifest(pp)
  end
end
