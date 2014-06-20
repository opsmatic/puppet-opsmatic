# opsmatic::puppet-reporter
#
include opsmatic::puppet-reporter-params

class opsmatic::puppet-reporter (
  $token = $opsmatic::puppet-reporter-params::token,
) inherits opsmatic::puppet-reporter-params {

  if $token == "" {
    fail("Your Opsmatic install token is not defined in \$token")
  }

  if $opsmatic_event_http == "" {
    fail("Your Opsmatic event service HTTP isn't defined in \$opsmatic_event_http")
  }

  case $operatingsystem {
    'Debian', 'Ubuntu': { include opsmatic::debian-public }
    default: { fail("Opsmatic Puppet Reporter is not supported on this platform") }
  }

  package { "opsmatic-puppet-reporter":
    ensure  => present,
    require => File["opsmatic_public_debian_repo"]
  }

  service { "opsmatic-puppet-reporter":
    require  => Package["opsmatic-puppet-reporter"],
    provider => upstart,
    enable   => true,
    ensure   => running
  }

  file { '/etc/init/opsmatic-puppet-reporter.conf':
    content => template("opsmatic::puppet-reporter/upstart.erb"),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '00644',
    notify  => Service['opsmatic-puppet-reporter'],
  }

}
