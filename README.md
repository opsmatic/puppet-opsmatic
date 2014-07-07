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

You can get these credentials from https://beta.opsmatic.com/docs/agent-installation

For all supported platforms, the following steps are carried out:

* The Opsmatic Beta repository is configured in your hosts package manager.
* An update is triggered.
* The latest version of the Opsmatic Agent and/or Puppet Reporter is installed and started.


If you ever want to purge the Opsmatic Agent or the Puppet Reporter from your hosts:

    class { 'opsmatic::puppet_reporter':
      ensure => 'absent';
    }


Attributes
----------

* `$token` - this is your integration token.

* `$credentials` - to the Opsmatic packages repo.


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
