# == Class: opsmatic::params
#
# Common class parameters for Opsmatic
#
# === Authors
#
# Opsmatic Inc. (support@opsmatic.com)
#
class opsmatic::params {
  # Default Puppet reporter state
  $puppet_reporter_ensure = 'present'

  # Default agent state
  $agent_ensure = 'present'

  # Default CLI tool state
  $cli_ensure = 'present'

  # Integration token
  $token = ''

  # Enable file watching
  $files_config_enabled = false

  # Paths to ignore by the Opsmatic Gent
  $paths_ignore = []

  # What groups the agent should be a member of in list format
  $groups = []

  # Opsmatic webhooks events endpoint
  $opsmatic_event_http = 'https://api.opsmatic.com/webhooks/events'

  # Location of the Puppet executable
  $puppet_bin = ''
}
