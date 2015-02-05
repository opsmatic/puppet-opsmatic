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

describe 'opsmatic::agent', :type => 'class' do

  context 'default params' do
    let(:facts) { FACTS }
    it do
      expect {
        should compile.with_all_deps
      }.to raise_error(/Opsmatic install token/)
    end
  end

  context 'token => 1234, files_config_enabled => true' do
    let(:facts) { FACTS }
    let(:params) {{
      :token => '1234', :files_config_enabled => true
    }}
    it do
      should compile.with_all_deps
      should contain_class('opsmatic::debian')
      should contain_package('opsmatic-agent').with(
        'ensure' => 'present')
      should contain_file('/etc/opsmatic-agent.conf').with(
        'content' => /paths_ignore = \[\]\nfiles_config_enabled = true\ngroups = ""/)
      should contain_exec('opsmatic_agent_initial_configuration').with(
        'command' => '/usr/bin/config-opsmatic-agent --token=1234')
      should contain_service('opsmatic-agent')
    end
  end

  context 'ensure => absent' do
    let(:facts) { FACTS }
    let(:params) {{
      :ensure => 'absent', :token => '1234'
    }}
    it do
      should compile.with_all_deps
      should_not contain_service('opsmatic-agent')
      should_not contain_exec('opsmatic_agent_initial_configuration')
      should contain_exec('kill-opsmatic-agent').with(
        'command' => 'killall -9 opsmatic-agent')
    end
  end

end
