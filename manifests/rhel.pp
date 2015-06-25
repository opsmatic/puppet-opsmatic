# == Class opsmatic::rhel
#
# Installs Opsmatic repo on a CentOS/RHEL host.
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::rhel {
  exec { 'Install Opsmatic Public Repo':
    command => 'curl -s https://packagecloud.io/install/repositories/opsmatic/public/script.rpm.sh | bash',
    path    => [ '/bin', '/usr/bin', '/sbin', '/usr/sbin' ],
    unless  => 'test -e /etc/yum.repos.d/opsmatic_public.repo',
    creates => '/etc/yum.repos.d/opsmatic_public.repo'
  }
}
