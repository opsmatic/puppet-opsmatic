# opsmatic-puppet-reporter
#
class opsmatic_puppet_reporter (
  $opsmatic_token = $opsmatic_puppet_reporter::params::opsmatic_token,
) inherits opsmatic_puppet_reporter::params {

  if $opsmatic_token == "" {
    fail("Your Opsmatic install token isn't defined in \$opsmatic_token")
  }

  if $opsmatic_event_http == "" {
    fail("Your Opsmatic event service HTTP isn't defined in \$opsmatic_event_http: $opsmatic_event_http $opsmatic_token")
  }

  case $operatingsystem {
    'Debian', 'Ubuntu': { include opsmatic_puppet_reporter::debian }
    default: { fail("Opsmatic Puppet Reporter isn't supported on this platform") }
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
    content => template("opsmatic_puppet_reporter/upstart.erb"),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '00644',
    notify  => Service['opsmatic-puppet-reporter'],
  }

}
