# @summary Apply this class to your dashboard node after enabling LDAP authentication
#
## Server Parameters
#
# @param ldap_host
#   FQDN or IP of the LDAP server (specify multiple hosts space separated).
#
# @param ldap_port
#   The port the LDAP service is listening on. Defaults to non-secure port 389.
#
# @param ldap_ssl
#   Enable the use of SSL.  Defaults to the false :: Set to true if LDAP server supports TLS
#
# @param ldap_tls
#   Set to true to connect LDAP server with STARTTLS pattern. Defaults to false.
#
# @param ldap_ssl_skip
#   Set to false if you do not want to skip SSL cert validation. Defaults to true.
#
# @param ldap_bind_dn
#   Search user bind dn. If you can provide a single bind expression that matches all possible users,
#   you can skip specifying ldap_bind_password.
#
# @param ldap_bind_password
#   Search user bind password. If the password contains # or ; you have to wrap it with triple quotes. Ex """#password;"""
#
# @param ldap_search_filter
#   User search filter, for example "(cn=%s)" or "(sAMAccountName=%s)" or "(uid=%s)"
#
# @param ldap_search_base
#   An array of base dns to search through
#
## If your LDAP server does not support the memberOf attribute add these options:
#
# @param ldap_groupsearch_filter
#   Group search filter, to retrieve the groups of which the user is a member (only set if memberOf attribute is not available)
#  
# @param ldap_groupsearch_base
#   An array of the base DNs to search through for groups.
#
# @param ldap_groupsearch_user_attr
#   The %s in ldap_groupsearch_filter will be replaced with the attribute defined here.
#
## Server Attributes Parameters: Specify names of the LDAP attributes your LDAP uses.
#
# @param ldap_name
#   
# @param ldap_surname
#
# @param ldap_username
#
# @param ldap_member_of
#
# @param ldap_email
#
## Group Mapping Parameters
#
# @param ldap_group_dn
#   Ldap DN of LDAP group. Will accept wildcard to match all groups "*".
#
# @param ldap_grafana_role
#    Assign users one of the following roles: "Admin", "Editor" or "Viewer". Defaults to "Admin".
#
class puppet_metrics_dashboard::profile::ldap_auth (
  String $ldap_host,
  String $ldap_bind_dn,
  String $ldap_search_filter,
  String $ldap_search_base,
  String $ldap_group_dn,
  Integer $ldap_port = 389,
  Boolean $ldap_ssl = false,
  Boolean $ldap_tls = false,
  Boolean $ldap_ssl_skip = true,
  String $ldap_grafana_role = 'Admin',
  Optional[String] $ldap_bind_password = null,
  Optional[String] $ldap_groupsearch_filter = null,
  Optional[String] $ldap_groupsearch_base = null,
  Optional[String] $ldap_groupsearch_user_attr = null,
  Optional[String] $ldap_name = name,
  Optional[String] $ldap_surname = surname,
  Optional[String] $ldap_username = username,
  Optional[String] $ldap_member_of = memberOf,
  Optional[String] $ldap_email = email,
){

  file { '/etc/grafana/ldap.toml':
    ensure  => present,
    content => epp('puppet_metrics_dashboard/ldap.toml.epp'),
    notify  => Service['grafana-server'],
  }
}
