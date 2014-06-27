# == Class opsmatic::debian
#
# Installs Opsmatic repo on a Debian host.
#
# === Authors
#
# <TODO>
#
class opsmatic::debian {

  apt::key { 'D59097AB':
    key_source => 'https://packagecloud.io/gpg.key',
  }

  apt::source { 'opsmatic_reporter_debian_repo':
    location    => 'https://packagecloud.io/opsmatic/public/any/',
    include_src => false,
    release     => 'any',
    repos       => 'main';
  }

}
