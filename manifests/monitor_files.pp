# == Class opsmatic::monitor_files
#
# Places file-integrity-monitoring JSON file in /var/db/opsmatic-agent/external.d/
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::monitor_files {
  case $::operatingsystem {
    'windows': {
    }
    default: {
      exec { '/var/db/opsmatic-agent/external.d':
              command => '/bin/mkdir -p /var/db/opsmatic-agent/external.d',
              creates => '/var/db/opsmatic-agent/external.d'
            }
      file { '/var/db/opsmatic-agent/external.d/filemonitoringlist.json':
              ensure  => 'file',
              owner   => 'root',
              group   => 'root',
              mode    => '0640',
              content => template('opsmatic/file-integrity-monitoring.json.erb'),
              path    => '/var/db/opsmatic-agent/external.d/filemonitoringlist.json',
              require => Exec['/var/db/opsmatic-agent/external.d']
            }
    }
  }
}
