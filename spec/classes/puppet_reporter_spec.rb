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

describe 'opsmatic::puppet_reporter', :type => 'class' do

  context 'default params' do
    let(:facts) { FACTS }
    it do
      expect {
        should compile.with_all_deps
      }.to raise_error(/Opsmatic install token/)
    end
  end

  context 'token => 1234' do
    let(:facts) { FACTS }
    let(:params) {{ :token => '1234' }}
    it do
      should compile.with_all_deps
      should contain_class('opsmatic::debian')
      should contain_package('opsmatic-puppet-reporter')
      should contain_service('opsmatic-puppet-reporter')
      should contain_file('/etc/init/opsmatic-puppet-reporter.conf').with(
        'content' => /api.opsmatic.com/)
    end
  end

end
