# == Class: opsmatic::params
#
# Common class parameters for the Opsmatic puppet class
#
# === Authors
#
# <TODO>
#
class opsmatic::params {

  # Integration token
  $token = ''

  # Opsmatic webhooks events endpoint
  $opsmatic_event_http = 'https://api.opsmatic.com/webhooks/events'

}
