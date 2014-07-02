# == Class: opsmatic-agent
#
# === Required Parameters
#
# [*token*]
#   The Global Install Token
#
# [*credentials*]
#   The credentials to install the Opsmatic agent package
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
class opsmatic::agent (
  $ensure      = $opsmatic::params::agent_ensure,
  $token       = $opsmatic::params::token,
  $credentials = $opsmatic::params::credentials,
) inherits opsmatic::params {

  if $token == '' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }

  if $credentials == '' {
    fail("Your Opsmatic credentials are not defined in ${credentials}")
  }

  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      class {'opsmatic::debian_private':
        credentials => $credentials,
      }
    }
    default: {
      fail('Opsmatic agent is not supported on this platform')
    }
  }

  # Install or uninstall the Opsmatic agent. If $ensure above is
  # absent, this will purge the agent.
  package { 'opsmatic-agent':
    ensure  => $ensure,
    require => Class['opsmatic::debian_private'];
  }

  # Now, if we are installing the agent, turn it on. If we're not, then
  # the upstart job config doesn't exist anyways so we cannot use a service
  # definition to stop the agent. Instead, we call an exec to kill it.
  case $ensure {
    'present', 'installed': {
      # Configure the agent client certs
      exec { 'opsmatic_agent_initial_configuration':
        command     => "/usr/bin/config-opsmatic-agent --token=${token}",
        onlyif      => [
          'test ! -f /var/db/opsmatic-agent/identity/host_id',
          'test ! -f /var/db/opsmatic-agent/identity/client-key.key',
          'test ! -f /var/db/opsmatic-agent/identity/client-pem.pem',
        ],
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
        notify  => Service['opsmatic-agent'],
        require => Package['opsmatic-agent'];
      }

      # Prepares the execution of the agent.
      service { 'opsmatic-agent':
        ensure    => 'running',
        enable    => true,
        provider  => upstart,
        require   => Package['opsmatic-agent'];
      }
    }
    default: {
      exec { 'kill-opsmatic-agent':
        command => 'killall -9 opsmatic-agent',
        onlyif  => 'pgrep -f opsmatic-agent',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ];
      }
    }
  }
}
