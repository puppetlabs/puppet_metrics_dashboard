# Change log

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org).

## 2020-12-30 - Release - 2.4.0

### Changes

 - Adds puppet7 testing / support
 - Support for multiple Postgres instances
 - Use supplied compiler name in dbcompiler profile
 - Add tidy_telegraf_configs option on dbcompiler profile
 - Introduces new cert_allowlist_entry class
 - Add local import and viewing of metrics
 - Updates the contrib docs for litmus
 - Re-adds dashboard for JRuby per-borrow metrics

### Bugfixes
 - Fix logic to select the v2 PuppetDB dashboards
 - Improve multiserver telegraf dashboard support
 - Fix raw queries in Postgres dashboard

## 2020-7-24 - Release - 2.3.1

### Changes
 - Added the `puppet_metrics_dashboard::profile::dbcompiler::install` class to mitigate CVE-2020-7943.
 - Added a description to the influxdb yumrepo
 - Updated Puppet VS Code Extension ID
 - Datasource is now configurable on te system metrics graphs
 - Replaced deprecated httpjson telegraf input with http
 - Added a dashboard for Telegraf Puppetserver workload

### Bugfixes
 - Fixed measurement names for process dashboards
 - CI fixes

## 2020-4-15 - Release - 2.3.0

### Changes
 - Account for [CVE-2020-7943](https://nvd.nist.gov/vuln/detail/CVE-2020-7943) by configuring telegraf to collect PuppetDB metrics from localhost only on the v2 metrics endpoint, updates dashboards to accomodate new values.
 - Added a tidy resource that cleans up unmanaged telegraf configuration in `/etc/telegraf/telegraf.d` if `tidy_telegraf_configs` is set to true in the main class (default is false)
 - Converted the acceptance tests from beaker to [litmus](https://github.com/puppetlabs/puppet_litmus)

### Bugfixes

## 2020-3-20 - Release - 2.2.0

### Changes
 - New and updated dashboards
 - Updated documentation
 - Use the client SSL certificate when querying PuppetDB metrics with Telegraf
 - Allow for specifying the PostgreSQL databases in the PostgreSQL profile
 - The certs defined type now uses a `file://` source since it's copying locally
 - Added the ability to set the Grafana admin password on initial deployment
 - Added the ability to pass arbitrary config options to Granfana

### Bugfixes
 - Remove the file sync query from PuppetDB metrics when `pe_server_version` is not defined when using Telegraf
 - Update the included dashboards to not reference deprecated `pe-` metrics
 - Compatibility fixes with OSP, including dashboards
 - Update module dependencies
 
## 2019-7-11 - Release - 2.0.1

### Bugfixes
 - Document a requirement on the toml-rb rem

## 2019-7-11 - Release - 2.0.0

### Changes
 - The module now supports configuring Telegraf on each Puppet infrastructure node in addition to configuring it on the same server that runs Grafana. This is to better support end-users that already have a Grafana instance and just want to collect Puppet metrics.  A set of profile classes has been added to allow for this.
 - Improvements to dashboard templates for Telegraf and archive.
 - Cleanup PuppetDB metrics in some versions.
 - `$telegraf_agent_interval` and `$http_response_timeout` in the main class are now Strings (previously integers) they should looks like: '5s', '2m' or '1h'.
 - `$influxdb_urls` has changed from a String to an Array. This is to support multiple Influxdb backends.
 - Instead of defining all of Telegraf's metrics in a single file `/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf`, there will now be multiple files for each metric.  An additional resource ensures that the old file is absent.
 - Replaced `params.pp` with module level hiera data.
 - Created a function for determining the needed PuppetDB metrics based
on PE version.
 - Removed the variable 'storage_metrics_db_queries' since it was not
referenced anywhere. 

### Bugfixes
 - Fix for Telegraf http timeouts not being set
 - Fix for cases where certname != FQDN

## 2019-4-25 - Release - 1.1.5

### Changes
 - Added a metric for last successful file-sync commit
 - Added puppetdb heap / status metrics
 - Improve FOSS puppet support
 - Allow port numbers of services to be specified

### Bugfixes
 - Stop creating /run/grafana on CentOS 7
 - Cleanup /run/grafana spec tests for ubuntu
 - Fixed grafana version req

## 2019-2-13 - Release - 1.1.0

### Changes
 - Code refactor to more standard layout
 - Various CI and testing updates
 - Updated apt-get / yum repo resources
 - New feature: postgres metrics
 - Moved telegraf config file from `/etc/telegraf/telegraf.conf` to `/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf`
 - The SSL dashboard option no longer relies on puppetlabs/puppet_agent
 - Tested and working on PE 2019.0.x

## 2018-11-30 - Release - 1.0.3

### Changes:
 - Minor fix for dependency versions

## 2018-08-03 - Release - 1.0.2

### Changes:
 - Added the missing license file.

## 2018-07-06 - Release - 1.0.1

### Bugfixes
- Fixed an issue with RHEL7 where the grafana service wouldn't start after rebooting
- Fixed an issue with metadata.json where some of the URLs were incorrect

## 2018-07-02 - Release - 1.0.0

Initial forge release
