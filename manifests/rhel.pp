# == Class opsmatic::rhel
#
# Installs Opsmatic repo on a CentOS/RHEL host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::rhel {
  case $::operatingsystemmajrelease {
    '6': {
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/6/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '0',
        gpgkey   => 'file://templates/D59097AB.key';
      }
    }
    '7': {
      yumrepo { 'opsmatic_rhel_repo_6':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/6/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '0',
        gpgkey   => 'file://templates/D59097AB.key';
      }
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'http://rpm.lab.opsmatic.com:3435/Opsmatic/7/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '0',
        gpgkey   => 'file://templates/D59097AB.key';
      }
    }
  }
}