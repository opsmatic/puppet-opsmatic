# == Class opsmatic::fileim
#
# Places file-integrity-monitoring JSON file in /var/db/opsmatic-agent/external.d/
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::fileim{
  file { '/var/db/opsmatic-agent/external.d':
          ensure => 'directory',
          owner  => 'root',
          group  => 'root',
          mode   => '0640',
        }
  file { '/var/db/opsmatic-agent/external.d/filemonitoringlist.json':
          ensure  => 'present',
          owner   => 'root',
          group   => 'root',
          mode    => '0640',
          content => template('opsmatic/file-integrity-monitoring.json.erb'),
        }
}
