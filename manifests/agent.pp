# == Class: opsmatic::agent
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
class opsmatic::agent (
  $ensure               = $opsmatic::params::agent_ensure,
  $token                = $opsmatic::params::token,
  $files_config_enabled = $opsmatic::params::files_config_enabled,
) inherits opsmatic::params {

  if $token == '' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }

  # Install or uninstall the Opsmatic agent. If $ensure above is
  # absent, this will purge the agent.
  case $::operatingsystem {
    'Debian', 'Ubuntu': {
      include opsmatic::debian
      if $ensure == 'latest' {
        package { 'opsmatic-agent':
          ensure  => $ensure,
          notify  => [
            Exec['opsmatic_agent_initial_configuration'],
            Service['opsmatic-agent'],
          ],
          require => [
            Exec['apt-get update'],
            Apt::Source['opsmatic_debian_repo'],
          ];
        }
      }
      elsif $ensure == 'absent' {
        package { 'opsmatic-agent':
          ensure  => $ensure,
        }
      }
      else {
        package { 'opsmatic-agent':
          ensure  => $ensure,
          notify  => [
            Exec['opsmatic_agent_initial_configuration'],
            Service['opsmatic-agent'],
          ],
          require => Apt::Source['opsmatic_debian_repo'],
        }
      }
    }
    'CentOS': {
      include opsmatic::rhel
      package { 'opsmatic-agent':
        ensure  => $ensure,
        notify  => [
          Exec['opsmatic_agent_initial_configuration'],
          Service['opsmatic-agent'],
        ],
        require => Yumrepo['opsmatic_rhel_repo'],
      }
    }
    default: {
      fail('Opsmatic Agent is not supported on this platform')
    }
  }

  # Now, if we are installing the agent, turn it on. If we're not, then
  # the upstart job config doesn't exist anyways so we cannot use a service
  # definition to stop the agent. Instead, we call an exec to kill it.
  case $ensure {
    'present', 'installed', 'latest': {
      file { '/etc/opsmatic-agent.conf':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => template('opsmatic/opsmatic-agent.conf.erb'),
      }

      # Configure the agent client certs
      exec { 'opsmatic_agent_initial_configuration':
        command => "/usr/bin/config-opsmatic-agent --token=${token}",
        onlyif  => [
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
        subscribe => File['/etc/opsmatic-agent.conf'],
        require   => Package['opsmatic-agent'],
      }
    }
    default: {
      file { '/etc/opsmatic-agent.conf':
        ensure  => 'absent',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => template('opsmatic/opsmatic-agent.conf.erb'),
      }

      exec { 'kill-opsmatic-agent':
        command => 'killall -9 opsmatic-agent',
        onlyif  => 'pgrep -f opsmatic-agent',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ];
      }
    }
  }
}
