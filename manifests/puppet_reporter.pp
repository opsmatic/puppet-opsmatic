# == Class: opsmatic-puppet_reporter
#
# === Required Parameters
#
# [*ensure*]
#   Install or uninstall the Puppet reporter
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
# <TODO>
#
class opsmatic::puppet_reporter (
  $ensure = $opsmatic::params::puppet_reporter_ensure,
  $token  = $opsmatic::params::token,
) inherits opsmatic::params {

  if $token == '' and $ensure == 'present' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      include opsmatic::debian-reporter
    }
    default: {
      fail('Opsmatic Puppet Reporter only supported on Debian and Ubuntu')
    }
  }

  # Install or uninstall the Opsmatic Puppet reporter. If $ensure above is
  # absent, this will purge the reporter.
  package { 'opsmatic-puppet-reporter':
    ensure  => $ensure,
    require => Class['opsmatic::debian-reporter'];
  }

  # Install or uninstall the upstart job configuration file.
  file { '/etc/init/opsmatic-puppet-reporter.conf':
    ensure  => $ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opsmatic/puppet_reporter_upstart.erb'),
  }

  # Now, if we are installing the service, turn it on. If we're not, then
  # the upstart job config doesn't exist anyways so we cannot use a service
  # definition to stop the service. Instead, we call an exec to kill it.
  case $ensure {
    'present', 'installed': {
      service { 'opsmatic-puppet-reporter':
        ensure    => 'running',
        enable    => true,
        provider  => upstart,
        subscribe => File['/etc/init/opsmatic-puppet-reporter.conf'],
        require   => [
          Package['opsmatic-puppet-reporter'],
          File['/etc/init/opsmatic-puppet-reporter.conf'],
        ];
      }
    }
    default: {
      exec { 'kill-opsmatic-puppet-reporter':
        command => 'killall -9 opsmatic-puppet-reporter',
        onlyif  => 'pgrep -f opsmatic-puppet-reporter',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ];
      }
    }
  }
}
