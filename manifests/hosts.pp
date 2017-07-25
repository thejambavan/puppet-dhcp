# Definition: dhcp::hosts
#
# Creates a dhcp configuration for the given hosts
#
# Parameters:
#   ['template']       -  DHCP host template - default: 'dhcp/host.conf.erb'
#   ['global_options'] -  An array of global options for the whole bunch of
#                         hosts.  You may override it per host, setting the
#                         host "options" directly in the hash.
#   ['subnet']         -  Targeted subnet
#   ['hash_data']      -  Hash containing data - default form:
#
# Requires:
#   - puppetlabs/stdlib
#
define dhcp::hosts (
  $hash_data,
  $subnet,
  $ensure = present,
  $global_options = [],
  $template = "${module_name}/group.conf.erb",
) {

  include ::dhcp::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_hash($hash_data)
  validate_string($subnet)
  validate_re($subnet, '^([1-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])(\.([0-9]|[1-9][0-9]|1[0-9][0-9]|2[0-4][0-9]|25[0-5])){3}$')
  validate_array($global_options)
  validate_string($template)

  if $ensure == 'present' {
    concat::fragment {"dhcp.host.${name}":
      target  => "${dhcp::params::config_dir}/hosts.d/${title}.conf",
      content => template($template),
      notify  => Service['dhcpd'],
    }
  }
}
