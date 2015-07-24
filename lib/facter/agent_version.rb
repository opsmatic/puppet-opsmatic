require 'facter'

Facter.add(:windows_agent_version) do
	confine :operatingsystem => 'windows'
	setcode do
		Facter::Util::Resolution.exec("\"C:\\Program Files\\Opsmatic\\opsmatic-agent\\opsmatic-agent.exe\" -version")
	end
end
