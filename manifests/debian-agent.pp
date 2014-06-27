# == Class opsmatic::debian-agent
#
# Installs Opsmatic repo on a Debian host.
#
# === Authors
#
# <TODO>
#
class opsmatic::debian-agent(
  $credentials = ''
) {

  apt::key { 'D59097AC':
    key_source => "https://${credentials}@apt.opsmatic.com/keyring.gpg",
  }

  apt::source { 'opsmatic_agent_public_debian_repo':
    location    => "https://${credentials}@apt.opsmatic.com",
    include_src => false,
    repos       => 'main';
  }

}
