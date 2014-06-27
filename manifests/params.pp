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

  # Integration token
  $token = ''

  # Agent credentials
  $credentials = ''

  # Opsmatic webhooks events endpoint
  $opsmatic_event_http = 'https://api.opsmatic.com/webhooks/events'

}
