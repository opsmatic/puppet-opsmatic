require 'facter'

Facter.add(:windows_puppet_reporter_version) do
	confine :operatingsystem => 'windows'
	setcode do
		Facter::Util::Resolution.exec("\"C:\\Program Files\\Opsmatic\\opsmatic-puppet-reporter\\opsmatic-puppet-reporter.exe\" -version")
	end
end
