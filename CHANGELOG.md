# Change log

## 2019-2-13 - Release - 1.1.0
### Summary

#### Changes
 - Code refactor to more standard layout
 - Various CI and testing updates
 - Updated apt-get / yum repo resources
 - New feature: postgres metrics
 - Moved telegraf config file from `/etc/telegraf/telegraf.conf` to `/etc/telegraf/telegraf.d/puppet_metrics_dashboard.conf`
 - The SSL dashboard option no longer relies on puppetlabs/puppet_agent
 - Tested and working on PE 2019.0.x

## 2018-11-30 - Release - 1.0.3
### Summary

#### Changes:
 - Minor fix for dependency versions

## 2018-08-03 - Release - 1.0.2
### Summary

#### Changes:
 - Added the missing license file.

## 2018-07-06 - Release - 1.0.1
### Summary

#### Bugfixes
- Fixed an issue with RHEL7 where the grafana service wouldn't start after rebooting
- Fixed an issue with metadata.json where some of the URLs were incorrect

## 2018-07-02 - Release - 1.0.0
### Summary

Initial forge release
