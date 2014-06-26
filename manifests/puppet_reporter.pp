# == Class: opsmatic-puppet_reporter
#
# === Authors
#
# <TODO>
#
class opsmatic::puppet_reporter (
  $token = $opsmatic::params::token,
) inherits opsmatic::params {

  if $token == '' {
    fail("Your Opsmatic install token is not defined in ${token}")
  }

  case $::operatingsystem {
    'Debian', 'Ubuntu': { include opsmatic::debian }
    default: { fail('Opsmatic Puppet Reporter only supported on Debian and Ubuntu') }
  }

  package { 'opsmatic-puppet-reporter':
    ensure  => present,
    require => File['opsmatic_public_debian_repo']
  }

  service { 'opsmatic-puppet-reporter':
    ensure   => running,
    enable   => true;
    provider => upstart,
    require  => Package['opsmatic-puppet-reporter'],
  }

  file { '/etc/init/opsmatic-puppet-reporter.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('opsmatic/puppet_reporter_upstart.erb'),
    notify  => Service['opsmatic-puppet-reporter'],
  }

}
