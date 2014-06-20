class opsmatic::puppet-reporter (
  $token = $opsmatic::params::token,
) inherits opsmatic::params {

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
    content => template("opsmatic/puppet_reporter_upstart.erb"),
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '00644',
    notify  => Service['opsmatic-puppet-reporter'],
  }

}
