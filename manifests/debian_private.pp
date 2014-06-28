# == Class opsmatic::debian_private
#
# Installs Opsmatic repo on a Debian host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::debian_private(
  $credentials = '',
) {

  if $credentials == '' {
    fail("Your Opsmatic credentials are not defined in ${credentials}")
  }

  apt::source { 'opsmatic_agent_private_debian_repo':
    location    => "https://${credentials}@apt.opsmatic.com",
    include_src => false,
    repos       => 'main',
    key         => 'CB1C35E2',
    key_source  => "https://${credentials}@apt.opsmatic.com/keyring.gpg",
  }

}
