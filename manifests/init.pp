# opsmatic-puppet-reporter
#
class puppet-opsmatic (
  $token = $puppet-opsmatic::params::token,
) inherits puppet-opsmatic::params {

  if $token == "" {
    fail("Your Opsmatic install token is not defined in \$token")
  }

  if $opsmatic_event_http == "" {
    fail("Your Opsmatic event service HTTP isn't defined in \$opsmatic_event_http")
  }

  case $operatingsystem {
    'Debian', 'Ubuntu': { include puppet-opsmatic::debian }
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
    content => template("puppet-opsmatic/upstart.erb"),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '00644',
    notify  => Service['opsmatic-puppet-reporter'],
  }

}
