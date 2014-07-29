# == Class opsmatic::rhel
#
# Installs Opsmatic repo on a CentOS/RHEL host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::rhel {
  yumrepo { 'opsmatic_rhel_repo':
    baseurl  => 'https://packagecloud.io/opsmatic/public/el/',
    descr    => 'Opsmatic RHEL repository',
    enabled  => '1',
    gpgcheck => '1',
    gpgkey   => template('opsmatic/D59097AB.key');
  }
}
