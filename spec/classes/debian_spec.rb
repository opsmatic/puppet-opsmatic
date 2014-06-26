require 'spec_helper'

# Facts mocked up for unit testing
FACTS = {
  :osfamily => 'Debian',
  :operatingsystem => 'Ubuntu',
  :operatingsystemrelease => '12',
  :lsbdistid => 'Ubuntu',
  :lsbdistcodename => 'precise',
  :lsbdistrelease => '12.04',
  :lsbmajdistrelease => '12',
  :kernel => 'linux',
}

describe 'opsmatic::debian', :type => 'class' do
  context 'default params' do
    let(:facts) { FACTS }
    it do
      should compile.with_all_deps
      should contain_apt__key('D59097AB').with(
        'key_source' => 'https://packagecloud.io/gpg.key')
      should contain_apt__source('opsmatic_public_debian_repo').with(
        'location' => 'https://packagecloud.io/opsmatic/public/any/')
    end
  end
end
