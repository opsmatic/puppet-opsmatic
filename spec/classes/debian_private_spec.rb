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

describe 'opsmatic::debian_private', :type => 'class' do
  context 'default params' do
    let(:facts) { FACTS }
    let(:params) {{ :credentials => 'foo:goo' }}
    it do
      should compile.with_all_deps
      should contain_apt__source('opsmatic_agent_private_debian_repo').with(
        'key'         => 'CB1C35E2',
        'key_content' => /mQENBFJ9ZXYBCACa/,
        'location'    => "https://foo:goo@apt.opsmatic.com")
    end
  end
end
