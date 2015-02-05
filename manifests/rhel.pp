# == Class opsmatic::rhel
#
# Installs Opsmatic repo on a CentOS/RHEL host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::rhel {
  file { '/etc/pki/rpm-gpg/9DAB4A7C_opsmatic-artifacts.key':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('opsmatic/9DAB4A7C.key'),
  }
  file { '/etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('opsmatic/D59097AB.key'),
  }
  exec { 'add Opsmatic GPG key':
    command => 'rpm --import /etc/pki/rpm-gpg/9DAB4A7C_opsmatic-artifacts.key',
    path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
    require => File['/etc/pki/rpm-gpg/9DAB4A7C_opsmatic-artifacts.key']
  }
  exec { 'add PackageCloud GPG key':
    command => 'rpm --import /etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key',
    path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
    require => File['/etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key']
  }
  case $::operatingsystemmajrelease {
    '6': {
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/6/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '1',
        repo_gpgcheck => '1',
        gpgkey   => 'file:///etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key'
      }
    }
    '7': {
      #CentOS 7 needs packages from both versions - opsmatic-cli in particular
      yumrepo { 'opsmatic_rhel_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/6/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '1',
        repo_gpgcheck => '1',
        gpgkey   => 'file:///etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key'
      }
      yumrepo { 'opsmatic_rhel7_repo':
        baseurl  => 'https://packagecloud.io/opsmatic/public/el/7/$basearch',
        descr    => 'Opsmatic RHEL repository',
        enabled  => '1',
        gpgcheck => '1',
        repo_gpgcheck => '1',
        gpgkey   => 'file:///etc/pki/rpm-gpg/D59097AB_packagecloud-repo.key'
      }
    }
    default: {
      fail('Opsmatic Puppet Reporter is not supported on this platform')
    }
  }
}
