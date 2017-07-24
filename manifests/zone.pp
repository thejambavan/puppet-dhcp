# Definition: dhcp::zone
#
# Creates a dns zone config file
#
# Parameters:
# ['zonename;] : DNS zone to use for updates
# ['ensure'] : 'present' or 'absent'
# ['primary_dns'] : primary DNS server (often 'localhost')
# ['ddns_key]' : ddns keyfile for updating ddns
#
# Sample usage:
#   dhcp::zone {"volcano.lair.":
#     ensure      => present,
#     primary_dns => '127.0.0.1',
#     key         => 'volcano',
#   }
#
#   dhcp::zone {"1.100.10.in-addr.arpa.":
#     ensure      => present,
#     primary_dns => '127.0.0.1',
#     key         => 'volcano',
#   }
define dhcp::zone(
  $zonename,
  $primary_dns,
  $ddns_key,
  $ensure = 'present',
) {

  Dhcp::Zone[$title] ~> Class['dhcp::server::service']

  include ::dhcp::params

  validate_string($ensure)
  validate_re($ensure, ['present', 'absent'],
              "\$ensure must be either 'present' or 'absent', got '${ensure}'")
  validate_string($zonename)
  validate_string($primary_dns)
  validate_string($ddns_key)

  file {"${dhcp::params::config_dir}/dhcpd.conf.d/${name}.conf":
    ensure  => $ensure,
    owner   => root,
    group   => root,
    content => template("${module_name}/zone.conf.erb"),
    notify  => Service['dhcpd'],
  }

  if $ensure == 'present' {
    concat::fragment {"dhcp.zone.${name}":
      target  => "${dhcp::params::config_dir}/dhcpd.conf",
      content => "include \"${dhcp::params::config_dir}/dhcpd.conf.d/${name}.conf\";\n",
    }
  }
}
