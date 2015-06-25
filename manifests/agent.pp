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
  $host_alias           = $opsmatic::params::host_alias,
  $filemonitorlist      = $opsmatic::params::filemonitorlist,
) inherits opsmatic::params {
  if $token == '' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }
  # Install or uninstall the Opsmatic agent. If $ensure above is
  # absent, this will purge the agent.
  case $::operatingsystem {
    'Debian': {
      include opsmatic::debian
      package { 'apt-transport-https':
        ensure          => $ensure,
        install_options => [ '--force-yes' ],
      }
      package { 'opsmatic-agent-sysv':
        ensure  => $ensure,
        require => Apt::Source['opsmatic_debian_repo']
      }
    }
    'Ubuntu': {
      include opsmatic::debian
      package { 'opsmatic-agent':
        ensure  => $ensure,
        require => Apt::Source['opsmatic_debian_repo']
      }
    }
    'RedHat', 'CentOS','Amazon': {
      include opsmatic::rhel
      case $::operatingsystemmajrelease {
        '6','2014','2015': {
          package { 'opsmatic-agent':
            ensure  => $ensure,
          }
        }
        '7': {
          package { 'opsmatic-agent-systemd':
            ensure  => $ensure,
          }
        }
        default: {
          fail('Opsmatic Agent is not supported on this platform')
        }
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
      include opsmatic::global
      include opsmatic::monitor_files
      file { '/etc/opsmatic-agent.conf':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => template('opsmatic/opsmatic-agent.conf.erb'),
      }
      case $::operatingsystem {
        'Debian': {
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
            require => Package['opsmatic-agent-sysv'];
          }
        }
        'Ubuntu': {
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
        }
        'RedHat', 'CentOS','Amazon': {
          case $::operatingsystemmajrelease {
            '6','2014','2015': {
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
            }
            '7': {
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
                require => Package['opsmatic-agent-systemd'];
              }
            }
            default: {
              fail('Opsmatic Agent is not supported on this platform')
            }
          }
        }
        default: {
          fail('Opsmatic Agent is not supported on this platform')
        }
      }

      case $::operatingsystem {
        'Debian': {
          service { 'opsmatic-agent':
            ensure     => 'running',
            hasrestart => true,
            hasstatus  => true,
            restart    => '/etc/init.d/opsmatic-agent restart',
            start      => '/etc/init.d/opsmatic-agent start',
            stop       => '/etc/init.d/opsmatic-agent stop',
            status     => '/etc/init.d/opsmatic-agent status | grep running',
            subscribe  => [ File['/etc/opsmatic-agent.conf'], File[ '/etc/default/opsmatic-global'] ],
            require    => Package['opsmatic-agent-sysv'];
          }
        }
        'Ubuntu': {
          service { 'opsmatic-agent':
            ensure     => 'running',
            hasrestart => true,
            hasstatus  => true,
            restart    => '/sbin/initctl restart opsmatic-agent',
            start      => '/sbin/initctl start opsmatic-agent',
            stop       => '/sbin/initctl stop opsmatic-agent',
            status     => '/sbin/initctl status opsmatic-agent | grep running',
            subscribe  => [ File['/etc/opsmatic-agent.conf'], File[ '/etc/default/opsmatic-global'] ],
            require    => Package['opsmatic-agent'];
          }
        }
        'RedHat', 'CentOS','Amazon': {
          case $::operatingsystemmajrelease {
            '6','2014','2015': {
              service { 'opsmatic-agent':
                ensure     => 'running',
                hasrestart => true,
                hasstatus  => true,
                restart    => '/sbin/initctl restart opsmatic-agent',
                start      => '/sbin/initctl start opsmatic-agent',
                stop       => '/sbin/initctl stop opsmatic-agent',
                status     => '/sbin/initctl status opsmatic-agent | grep running',
                subscribe  => [ File['/etc/opsmatic-agent.conf'], File[ '/etc/default/opsmatic-global'] ],
                require    => Package['opsmatic-agent'];
              }
            }
            '7': {
              service { 'opsmatic-agent':
                ensure     => 'running',
                hasrestart => true,
                hasstatus  => true,
                restart    => '/bin/systemctl restart opsmatic-agent',
                start      => '/bin/systemctl start opsmatic-agent',
                stop       => '/bin/systemctl stop opsmatic-agent',
                status     => '/sbin/initctl status opsmatic-agent | grep running',
                subscribe  => [ File['/etc/opsmatic-agent.conf'], File[ '/etc/default/opsmatic-global'] ],
                require    => Package['opsmatic-agent-systemd'];
              }
            }
            default: {
              fail('Opsmatic Agent is not supported on this platform')
            }
          }
        }
        default: {
          fail('Opsmatic Agent is not supported on this platform')
        }
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
      file { '/var/db/opsmatic-agent':
        ensure  => 'absent',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
      }
      file { '/etc/default/opsmatic-global':
        ensure  => 'absent',
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => template('opsmatic/opsmatic-global.erb'),
      }
      exec { 'kill-opsmatic-agent':
        command => 'killall -9 opsmatic-agent',
        onlyif  => 'pgrep -f opsmatic-agent',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ];
      }
    }
  }
}
