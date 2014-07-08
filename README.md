Opsmatic Puppet Module
======================

[![Build Status](https://travis-ci.org/opsmatic/puppet-opsmatic.svg?branch=master)](https://travis-ci.org/opsmatic/puppet-opsmatic)


Overview
--------

This module installs and configures the Opsmatic Puppet Reporter and the Opsmatic Agent.


Requirements
------------

The Opsmatic Puppet Reporter and the Opsmatic Agent are supported on the following platforms:

  * Ubuntu: 10.04, 11.04, 11.10, 12.04, 12.10, 13.04, 13.10 and 14.04.
  * Debian: 7.x.


Usage
-----

To use this module to install Opsmatic Puppet Reporter you will need to set the variable `$token` in
your puppet configuration:

    class { 'opsmatic::puppet_reporter':
      token => 'my_integration_token',
    }

and make sure to set the report setting in your `puppet.conf` to true in order to turn on reporting capabilities on agent nodes:

    [agent]
        report = true

After that, the manifest will handle the appropriate platform detection and configuration. The Puppet Reporter will run as a daemon waiting for changes performed by Puppet runs, and reporting the results to Opsmatic.

To use this module to install Opsmatic Agent you will need to set the variable `$token` and your credentials `$credentials` in
your puppet configuration:

    class { 'opsmatic::agent':
      token => 'my_integration_token',
      credentials => 'my_credentials',
    }

You can get these credentials from https://beta.opsmatic.com/docs/agent-installation.

It is possible to specify a list of paths that should not be monitored by the agent, via the variable `$paths_ignore`: 

    class { 'opsmatic::agent':
      paths_ignore => ['/etc/alternatives'],
    }

For a more in depth explanation of `$paths_ignore`, please visit the documentation in https://beta.opsmatic.com/docs/agent-configuration.

Finally, if you ever want to purge the Opsmatic Agent or the Puppet Reporter from your hosts, use the following:

    class { 'opsmatic::puppet_reporter':
      ensure => 'absent';
    }


Attributes
----------

* `$token` - this is your integration token.
* `$credentials` - to the Opsmatic packages repo.
* `$ensure` - to ensure the Agent or Puppet Reporter is installed or uninstalled.
* `$paths_ignore` - list of paths to ignore (not monitor).


Support
-------

Please create bug reports and feature requests in [GitHub issues] [1]. And feel free to contribute:

1. Fork it ( https://github.com/opsmatic/puppet-opsmatic/fork ).
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.

[1]: https://github.com/opsmatic/puppet-opsmatic/issues

Author:: Opsmatic Inc. (<support@opsmatic.com>)
