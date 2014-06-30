# == Class opsmatic::debian
#
# Installs Opsmatic repo on a Debian host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::debian {
  apt::source { 'opsmatic_debian_repo':
    location    => 'https://packagecloud.io/opsmatic/public/any/',
    include_src => false,
    release     => 'any',
    repos       => 'main',
    key         => 'D59097AB',
    key_content => template('opsmatic/D59097AB.key');
  }
}
