class opsmatic::puppet-reporter (
  $token = $opsmatic::params::token,
) inherits opsmatic::params {

  if $token == "" {
    fail("Your Opsmatic install token is not defined in \$token")
  }

  if $opsmatic_event_http == "" {
    fail("Your Opsmatic event service HTTP isn't defined in \$opsmatic_event_http")
  }

  case $operatingsystem {
    'Debian', 'Ubuntu': { include opsmatic::debian }
    default: { fail("Opsmatic Puppet Reporter is not supported on this platform") }
  }

  include opsmatic::puppet-reporter

}
