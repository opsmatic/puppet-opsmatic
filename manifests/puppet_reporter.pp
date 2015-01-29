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
  case $::operatingsystem {
    'Debian': {
      include opsmatic::debian
      package { 'apt-transport-https':
        install_options => [ '--force-yes' ],
        ensure  => $ensure
      }
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
    'CentOS': {
      include opsmatic::rhel
      case $::operatingsystemmajrelease {
        '6': {
          package { 'opsmatic-puppet-reporter':
            ensure  => $ensure,
            require => Yumrepo['opsmatic_rhel_repo'],
          }
        }
        '7': {
          package { 'opsmatic-puppet-reporter-systemd':
            ensure  => $ensure,
            require => Yumrepo['opsmatic_rhel_repo'],
          }
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
          file { '/etc/init/opsmatic-puppet-reporter.conf':
            ensure  => 'present',
            owner   => 'root',
            group   => 'root',
            mode    => '0644',
            content => template('opsmatic/puppet_reporter_upstart.erb'),
          }
          service { 'opsmatic-puppet-reporter':
            ensure    => 'running',
            enable    => true,
            hasrestart => true,
            hasstatus => true,
            restart => '/sbin/initctl restart opsmatic-puppet-reporter',
            start => '/sbin/initctl start opsmatic-puppet-reporter',
            stop => '/sbin/initctl stop opsmatic-puppet-reporter',
            status => '/sbin/initctl status opsmatic-puppet-reporter | grep running',
            subscribe => File['/etc/init/opsmatic-puppet-reporter.conf'],
            require   => [
              Package['opsmatic-puppet-reporter'],
              File['/etc/init/opsmatic-puppet-reporter.conf'],
            ];
          }
        }
        'Centos': {
          case $::operatingsystemmajrelease {
            '6': {
              file { '/etc/init/opsmatic-puppet-reporter.conf':
                ensure  => 'present',
                owner   => 'root',
                group   => 'root',
                mode    => '0644',
                content => template('opsmatic/puppet_reporter_upstart.erb'),
              }
              service { 'opsmatic-puppet-reporter':
                  ensure    => 'running',
                  enable    => true,
                  hasstatus => true,
                  restart => '/sbin/initctl restart opsmatic-puppet-reporter',
                  start => '/sbin/initctl start opsmatic-puppet-reporter',
                  stop => '/sbin/initctl stop opsmatic-puppet-reporter',
                  status => '/sbin/initctl status opsmatic-puppet-reporter | grep running',
                  subscribe => File['/etc/init/opsmatic-puppet-reporter.conf'],
                  require   => [
                    Package['opsmatic-puppet-reporter'],
                    File['/etc/init/opsmatic-puppet-reporter.conf'],
                  ];
              }
            }
          }
        }
      }
    }
  }
  case $::operatingsystem {
    'Debian': {
      service { 'opsmatic-puppet-reporter':
          ensure    => 'running',
          enable    => true,
          hasrestart => true,
          hasstatus => true,
          restart => '/etc/init.d/opsmatic-puppet-reporter restart',
          start => '/etc/init.d/opsmatic-puppet-reporter start',
          stop => '/etc/init.d/opsmatic-puppet-reporter stop',
          status => '/etc/init.d/opsmatic-puppet-reporter status | grep running',
          require   => [
            Package['opsmatic-puppet-reporter-sysv']
          ];
      }
    }
    'Centos': {
      case $::operatingsystemmajrelease {
        '7': {
          service { 'opsmatic-puppet-reporter':
              ensure    => 'running',
              enable    => true,
              hasstatus => true,
              restart => '/bin/systemctl restart opsmatic-puppet-reporter',
              start => '/bin/systemctl start opsmatic-puppet-reporter',
              stop => '/bin/systemctl stop opsmatic-puppet-reporter',
              status => '/bin/systemctl status opsmatic-puppet-reporter | grep running',
              require   => [
                Package['opsmatic-puppet-reporter-systemd']
              ];
          }
        }
      }
    }
    default: {
      file { '/etc/init/opsmatic-puppet-reporter.conf':
        ensure  => 'absent',
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        content => template('opsmatic/puppet_reporter_upstart.erb'),
      }

      exec { 'kill-opsmatic-puppet-reporter':
        command => 'killall -9 opsmatic-puppet-reporter',
        onlyif  => 'pgrep -f opsmatic-puppet-reporter',
        path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ];
      }
    }
  }
}