## Version 0.1.4

* Added support/testing for setting service environment variables, closes #3 (thanks @klamontagne)

## Version 0.1.3

* Fixed stock service resource initialization and proxying, fixes #2  (thanks @srenatus)
* Upstart provider now compliant with Debian policy 9.11.1 - init.d compatibility
* Improved testing for resource notifications and auto-starting services
* Added support/testing for removal of PID files after services are stopped
* Further integration of run_action_now cookbook
* Added some examples to documentation

## Version 0.1.2

* Fixed SysV services not returning proper status codes
* Fixed some Chef includes
* Updated default to SysV if no better provider determined
* Updated to depend on 'run_action_now' cookbook (code-reuse)
* Updated to use Unix Mock Service Daemon (code-reuse)
* Added :path_variables resource attribute

## Version 0.1.1

Initial release.
