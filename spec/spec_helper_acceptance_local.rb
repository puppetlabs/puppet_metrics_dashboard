# frozen_string_literal: true

require 'puppetlabs_spec_helper/module_spec_helper'
require 'serverspec'
include PuppetLitmus

RSpec.configure do |c|
  c.mock_with :rspec
  c.before :suite do
    run_shell('sudo setenforce 0')
    # Fake the SSL certificates
    run_shell('mkdir -p /etc/puppetlabs/puppet/ssl/{certs,private_keys}')
    run_shell('touch $(/opt/puppetlabs/bin/puppet config print localcacert) \
                $(/opt/puppetlabs/bin/puppet config print hostcert) \
                $(/opt/puppetlabs/bin/puppet config print hostprivkey)')
    pp = <<-PUPPETCODE
      package{'toml-rb':
        ensure   => installed,
        provider => puppet_gem,
      }
      if $facts['os']['family'] == 'Debian' {
        package{['lsb-release','iproute2']:
          ensure => installed,
        }
      }
    PUPPETCODE
    apply_manifest(pp)
  end
end
