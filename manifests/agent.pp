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
  $ensure                   = $opsmatic::params::agent_ensure,
  $token                    = $opsmatic::params::token,
  $host_alias               = $opsmatic::params::host_alias,
  $filemonitorlist          = $opsmatic::params::filemonitorlist,
  $agent_simple_options_num = $opsmatic::params::agent_simple_options_num,
  $agent_simple_options_str = $opsmatic::params::agent_simple_options_str,
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
        '6','2015': {
          package { 'opsmatic-agent':
            ensure  => $ensure,
            require => Yumrepo['opsmatic_rhel_repo'],
          }
        }
        '7': {
          package { 'opsmatic-agent-systemd':
            ensure  => $ensure,
            require => Yumrepo['opsmatic_rhel7_repo'],
          }
        }
        default: {
          fail('Opsmatic Agent is not supported on this platform')
        }
      }
    }
    'windows': {
      # On Windows, $ensure must be the version of the agent to use.
      # Supports a specific version only (example: 1.0.321)
      $target_version = $ensure
      $target_version_parts = split($target_version, '[.]')
      $target_build = $target_version_parts[2]

      if !$::windows_agent_version or !($target_build in $::windows_agent_version) {
        $windows_staging_dir_agent = "${opsmatic::params::windows_staging_dir}\\opsmatic-agent-installer"
        $agent_version_staging_dir = "${windows_staging_dir_agent}\\${target_version}"
        file { [$windows_staging_dir_agent, $agent_version_staging_dir]:
          require => File[$opsmatic::params::windows_staging_dir],
          ensure  => 'directory'
        }
        download_file { 'Opsmatic Agent Installer':
          require               => File[$agent_version_staging_dir],
          url                   => "${opsmatic::params::download_base}/opsmatic-agent/windows_386/opsmatic-agent_${target_version}_windows_386.zip",
          destination_directory => $agent_version_staging_dir,
          proxyAddress          => $opsmatic::params::download_proxy_address
        }

        $win_unzip_zipfile = "${agent_version_staging_dir}\\opsmatic-agent_${target_version}_windows_386.zip"
        $win_unzip_dest    = $agent_version_staging_dir
        exec { "Unzip Agent Installer":
          require  => Download_file['Opsmatic Agent Installer'],
          command  => template("opsmatic/unzip.ps1.erb"),
          provider => 'powershell',
          creates  => "${agent_version_staging_dir}\\opsmatic-agent.exe"
        }

        exec { "Install Opsmatic Agent":
          require => Exec["Unzip Agent Installer"],
          command => "${agent_version_staging_dir}\\config-opsmatic-agent.exe -token ${token}"
        }
        file { 'C:\Program Files\Opsmatic\opsmatic-agent\opsmatic-agent.conf':
          require => Exec['Install Opsmatic Agent'],
          ensure  => 'present',
          content => template('opsmatic/opsmatic-agent.conf.erb')
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
  case $::operatingsystem {
    'windows': {
      # Skip this portion of the manifest for Windows - all is handled above.
    }
    default: {
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
                '6','2015': {
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
                '6','2015': {
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
  }
}
