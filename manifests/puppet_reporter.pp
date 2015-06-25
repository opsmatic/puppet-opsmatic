# == Class: opsmatic::puppet_reporter
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
class opsmatic::puppet_reporter (
  $ensure = $opsmatic::params::puppet_reporter_ensure,
  $token  = $opsmatic::params::token,
) inherits opsmatic::params {

  if $token == '' and $ensure == 'present' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }

  # Install or uninstall the Opsmatic Puppet Reporter. If $ensure above is
  # absent, this will purge the reporter.
  include opsmatic::global
  case $::operatingsystem {
    'Debian': {
      include opsmatic::debian
      package { 'opsmatic-puppet-reporter-sysv':
        ensure  => $ensure,
        require => Apt::Source['opsmatic_debian_repo']
      }
    }
    'Ubuntu': {
      include opsmatic::debian
      package { 'opsmatic-puppet-reporter':
        ensure  => $ensure,
        require => Apt::Source['opsmatic_debian_repo']
      }
    }
    'RedHat', 'CentOS', 'Amazon': {
      include opsmatic::rhel
      case $::operatingsystemmajrelease {
        '6','2014','2015': {
          package { 'opsmatic-puppet-reporter':
            ensure  => $ensure,
          }
        }
        '7': {
          package { 'opsmatic-puppet-reporter-systemd':
            ensure  => $ensure,
          }
        }
        default: {
          fail('Opsmatic Puppet Reporter is not supported on this platform')
        }
      }
    }
    default: {
      fail('Opsmatic Puppet Reporter is not supported on this platform')
    }
  }

  # Now, if we are installing the service, turn it on. If we're not, then
  # the upstart job config doesn't exist anyways so we cannot use a service
  # definition to stop the service. Instead, we call an exec to kill it.
  case $ensure {
    'present', 'installed', 'latest': {
      case $::operatingsystem {
        'Ubuntu': {
          service { 'opsmatic-puppet-reporter':
            ensure     => 'running',
            hasrestart => true,
            hasstatus  => true,
            restart    => '/sbin/initctl restart opsmatic-puppet-reporter',
            start      => '/sbin/initctl start opsmatic-puppet-reporter',
            stop       => '/sbin/initctl stop opsmatic-puppet-reporter',
            status     => '/sbin/initctl status opsmatic-puppet-reporter | grep running',
            subscribe  => [ Package['opsmatic-puppet-reporter'], File[ '/etc/default/opsmatic-global'] ],
            require    => [
              Package['opsmatic-puppet-reporter'],
            ];
          }
        }
        'Debian': {
          service { 'opsmatic-puppet-reporter':
            ensure     => 'running',
            hasrestart => true,
            hasstatus  => true,
            restart    => '/etc/init.d/opsmatic-puppet-reporter restart',
            start      => '/etc/init.d/opsmatic-puppet-reporter start',
            stop       => '/etc/init.d/opsmatic-puppet-reporter stop',
            status     => '/etc/init.d/opsmatic-puppet-reporter status | grep running',
            subscribe  => [ Package['opsmatic-puppet-reporter-sysv'], File[ '/etc/default/opsmatic-global'] ],
            require    => [
              Package['opsmatic-puppet-reporter-sysv']
            ];
          }
        }
        'RedHat', 'CentOS', 'Amazon': {
          case $::operatingsystemmajrelease {
            '6','2014','2015': {
              service { 'opsmatic-puppet-reporter':
                  ensure    => 'running',
                  hasstatus => true,
                  restart   => '/sbin/initctl restart opsmatic-puppet-reporter',
                  start     => '/sbin/initctl start opsmatic-puppet-reporter',
                  stop      => '/sbin/initctl stop opsmatic-puppet-reporter',
                  status    => '/sbin/initctl status opsmatic-puppet-reporter | grep running',
                  subscribe => [ Package['opsmatic-puppet-reporter'], File[ '/etc/default/opsmatic-global'] ],
                  require   => [
                    Package['opsmatic-puppet-reporter'],
                  ];
              }
            }
            '7': {
              service { 'opsmatic-puppet-reporter':
                  ensure    => 'running',
                  hasstatus => true,
                  restart   => '/bin/systemctl restart opsmatic-puppet-reporter',
                  start     => '/bin/systemctl start opsmatic-puppet-reporter',
                  stop      => '/bin/systemctl stop opsmatic-puppet-reporter',
                  status    => '/bin/systemctl status opsmatic-puppet-reporter | grep running',
                  subscribe => [ Package['opsmatic-puppet-reporter-systemd'], File[ '/etc/default/opsmatic-global'] ],
                  require   => [
                    Package['opsmatic-puppet-reporter-systemd']
                  ];
              }
            }
            default: {
              fail('Opsmatic Puppet Reporter is not supported on this platform')
            }
          }
        }
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
