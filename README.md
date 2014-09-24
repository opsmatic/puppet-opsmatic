Opsmatic Puppet Module
======================

[![Build Status](https://travis-ci.org/opsmatic/puppet-opsmatic.svg?branch=master)](https://travis-ci.org/opsmatic/puppet-opsmatic)


Overview
--------

This module installs and configures the Opsmatic Puppet Reporter, Opsmatic Agent, and Opsmatic CLI tool.


Requirements
------------

The Opsmatic Puppet Reporter, Opsmatic Agent, and Opsmatic CLI tool are supported on the following platforms:

  * Ubuntu: 10.04, 11.04, 11.10, 12.04, 12.10, 13.04, 13.10 and 14.04.
  * CentOS: 6.x.


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

The Puppet Reporter uses the `puppet` executable command to discover certain configuration values of your infrastructure.
If the path of the `puppet` executable command is not in your `$PATH`, you will need to set the variable `$puppet_bin`
in your puppet configuration:

    class { 'opsmatic::puppet_reporter':
      token => 'my_integration_token',
      puppet_bin => '/usr/bin',
    }

To use this module to install the Opsmatic Agent or the Opsmatic CLI tool you will need to set the variable `$token` in your puppet configuration:

    class { 'opsmatic::agent':
      token => 'my_integration_token',
    }

and to install the Opsmatic CLI tool, simply include the following:

    class { 'opsmatic::cli':
    }

Finally, if you ever want to purge the Opsmatic Puppet Reporter, Opsmatic Agent, and Opsmatic CLI tool from any of your hosts, change the variable `$ensure` to the following:

    class { 'opsmatic::puppet_reporter':
      ensure => 'absent',
    }


Attributes
----------

* `$token` - this is your integration token.
* `$ensure` - ensure the Opsmatic Puppet Reporter, Opsmatic Agent, or Opsmatic CLI tool is installed or not. Give it the value `latest` to install the latest version available of the package.


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
