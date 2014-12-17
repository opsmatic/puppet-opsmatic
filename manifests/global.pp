# == Class opsmatic::global
#
# Places global config file in /etc/default
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::global {
  file { '/etc/default/opsmatic-global':
          ensure  => 'present',
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => template('opsmatic/opsmatic-global.erb'),
        }
}