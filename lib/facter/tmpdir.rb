require 'tmpdir'

Facter.add(:windows_temp_dir) do
	confine :operatingsystem => 'windows'
	setcode do
		(Dir.tmpdir || ENV['TEMP']).gsub(/\\\s/, " ").gsub(/\//, '\\')
	end
end
