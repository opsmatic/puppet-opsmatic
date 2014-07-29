require 'spec_helper'

# Facts mocked up for unit testing
REDHAT_FACTS = {
  :osfamily => 'RedHat',
  :operatingsystem => 'CentOS',
  :lsbdistid => 'CentOS',
  :lsbdistrelease => '6',
  :kernel => 'linux',
}

describe 'opsmatic::rhel', :type => 'class' do
  context 'default params' do
    let(:facts) { REDHAT_FACTS }
    it do
      should contain_yumrepo('opsmatic_rhel_repo').with(
        'enabled'  => '1',
        'gpgcheck' => '1',
        'baseurl' => 'https://packagecloud.io/opsmatic/public/el/',
        'gpgkey' => /mQINBFLUbogBEADceEoxBDoE6QM5xV/)
    end
  end
end