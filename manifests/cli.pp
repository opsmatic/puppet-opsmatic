# == Class: opsmatic::cli
#
# === Required Parameters
#
# [*token*]
#   The Global Install Token
#
# === Optional Parameters
#
# [*ensure*]
#   Whether to ensure its installed, or ensure its uninstalled.
#   (default: present) (options: present/absent)
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::cli (
  $ensure = $opsmatic::params::cli_ensure,
) inherits opsmatic::params {

  # Install or uninstall the Opsmatic CLI tools. If $ensure above is
  # absent, this will purge the tool.
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      include opsmatic::global
      include opsmatic::debian
      package { 'opsmatic-cli':
        ensure    => $ensure,
        require   => Apt::Source['opsmatic_debian_repo'],
        subscribe => File['/etc/default/opsmatic-global'],
      }
    }
    'RedHat','CentOS', 'Amazon': {
      include opsmatic::global
      include opsmatic::rhel
      package { 'opsmatic-cli':
        ensure    => $ensure,
        subscribe => File['/etc/default/opsmatic-global'],
      }
    }
    default: {
      fail('Opsmatic CLI tool is not supported on this platform')
    }
  }
}
