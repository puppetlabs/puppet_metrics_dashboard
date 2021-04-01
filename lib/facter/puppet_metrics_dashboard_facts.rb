Facter.add(:puppet_metrics_dashboard) do
  confine kernel: 'linux'

  setcode do
    result = { versions: {} }
    if File.readable?('/opt/puppetlabs/server/apps/puppetdb/ezbake.manifest')
      version = File.read('/opt/puppetlabs/server/apps/puppetdb/ezbake.manifest').match(%r{puppetlabs/puppetdb "(.*)"})

      result[:versions][:puppetdb] = version.captures.first.gsub(%r{^(\d+\.\d+\.\d+).*}, '\1') unless version.nil?
    end

    result[:overwrite_dashboards_disabled] = File.exist?('/opt/puppetlabs/puppet/cache/state/overwrite_dashboards_disabled')

    result
  end
end
