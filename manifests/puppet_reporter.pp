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
# [*opsmatic_event_http*]
#   URL to publish Opsmatic events to.
#   (default: https://api.opsmatic.com/webhooks/events)
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::puppet_reporter (
  $ensure              = $opsmatic::params::puppet_reporter_ensure,
  $token               = $opsmatic::params::token,
  $opsmatic_event_http = $opsmatic::params::opsmatic_event_http,
) inherits opsmatic::params {
  case $::operatingsystem {
    'windows': {
      # On Windows, $ensure must be the version of the agent to use.
      # Supports a specific version only (example: 1.0.321)
      $target_version = $ensure
      $target_version_parts = split($target_version, '[.]')
      $target_build = $target_version_parts[2]

      if $token == '' {
        fail("Your Opsmatic integration token is not defined in ${token}")
      }

      if !$::windows_puppet_reporter_version or !($target_build in $::windows_puppet_reporter_version) {
        $windows_staging_dir_reporter = "${opsmatic::params::windows_staging_dir}\\opsmatic-puppet-reporter"
        $reporter_version_staging_dir = "${windows_staging_dir_reporter}\\${target_version}"
        file { [$windows_staging_dir_reporter, $reporter_version_staging_dir]:
          ensure  => 'directory',
          require => File[$opsmatic::params::windows_staging_dir]
        }
        download_file { 'Opsmatic Puppet Reporter Installer':
          require               => File[$reporter_version_staging_dir],
          url                   => "${opsmatic::params::download_base}/opsmatic-puppet-reporter/windows_386/opsmatic-puppet-reporter_${target_version}_windows_386.zip",
          destination_directory => $reporter_version_staging_dir,
          proxyAddress          => $opsmatic::params::download_proxy_address
        }

        $win_unzip_zipfile = "${reporter_version_staging_dir}\\opsmatic-puppet-reporter_${target_version}_windows_386.zip"
        $win_unzip_dest    = $reporter_version_staging_dir
        exec { 'Unzip Puppet Reporter Installer':
          require  => Download_file['Opsmatic Puppet Reporter Installer'],
          command  => template('opsmatic/unzip.ps1.erb'),
          provider => 'powershell',
          creates  => "${reporter_version_staging_dir}\\opsmatic-puppet-reporter.exe"
        }

        exec { 'Install Opsmatic Puppet Reporter':
          require => Exec['Unzip Puppet Reporter Installer'],
          command => "${reporter_version_staging_dir}\\install-opsmatic-puppet-reporter.exe -token ${token}"
        }
      }
    }
    default: {
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
            '6','2015': {
              package { 'opsmatic-puppet-reporter':
                ensure  => $ensure,
                require => Yumrepo['opsmatic_rhel_repo'],
              }
            }
            '7': {
              package { 'opsmatic-puppet-reporter-systemd':
                ensure  => $ensure,
                require => Yumrepo['opsmatic_rhel7_repo'],
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
          file { '/etc/opsmatic':
            ensure  => 'directory',
            owner   => 'root',
            group   => 'root',
            mode    => '0640'
          }
          file { '/etc/opsmatic/opsmatic-puppet-reporter.conf':
            ensure  => 'present',
            require => File['/etc/opsmatic'],
            owner   => 'root',
            group   => 'root',
            mode    => '0640',
            content => template('opsmatic/opsmatic-puppet-reporter.conf.erb'),
          }

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
                '6','2015': {
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
          file { '/etc/opsmatic/opsmatic-puppet-reporter.conf':
            ensure  => 'absent'
          }
        }
      }
    }
  }
}
