# == Class opsmatic::rhel
#
# Installs Opsmatic repo on a CentOS/RHEL host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
case $::operatingsystemmajrelease {
  '6': {
    class opsmatic::rhel {
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/6/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '0',
        gpgkey   => 'file://templates/D59097AB.key';
      }
    }
  }
  '7': {
    class opsmatic::rhel {
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/7/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '0',
        gpgkey   => 'file://templates/D59097AB.key';
      }
    }
  }
}