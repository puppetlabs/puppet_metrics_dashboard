# Change log

All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/) and this project adheres to [Semantic Versioning](http://semver.org).

## 2020-1-13 - Release - 2.0.2

### Bugfixes
 - Update the included dashboards to not reference deprecated `pe-` metrics

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
