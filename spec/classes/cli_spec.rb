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

describe 'opsmatic::cli', :type => 'class' do

  context 'default params' do
    let(:facts) { FACTS }
    it do
      should compile.with_all_deps
    end
  end

  context 'ensure => absent' do
    let(:facts) { FACTS }
    let(:params) {{ :ensure => 'absent' }}
    it do
      should compile.with_all_deps
      should contain_package('opsmatic-cli').with(
        'ensure' => 'absent')
    end
  end

end
