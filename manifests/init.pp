class opsmatic::init (
  $token = $opsmatic::params::token,
) inherits opsmatic::params {

  if $token == "" {
    fail("Your Opsmatic install token is not defined in \$token")
  }

  include opsmatic::puppet-reporter

}
