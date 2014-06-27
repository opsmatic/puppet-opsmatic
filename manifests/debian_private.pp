# == Class opsmatic::debian_private
#
# Installs Opsmatic repo on a Debian host.
#
# === Authors
#
# <TODO>
#
class opsmatic::debian_private(
  $credentials = ''
) {

  apt::key { 'CB1C35E2':
    key_source => "https://${credentials}@apt.opsmatic.com/keyring.gpg",
  }

  apt::source { 'opsmatic_agent_private_debian_repo':
    location    => "https://${credentials}@apt.opsmatic.com",
    include_src => false,
    repos       => 'main';
  }

}
