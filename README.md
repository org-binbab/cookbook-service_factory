# service_factory cookbook

Cookbook for Opscode Chef.

http://community.opscode.com/cookbooks/service_factory

**Fully functional … documentation WIP, and example usages coming soon !!**


# Description

Generate services using native system features with the **service_factory** LWRPs.

Your recipe provides the configuration details, and the necessary files are generated to create a **SysV** or **Upstart** service, depending on what each OS prefers. (**SystemD** coming soon!!)

**Supported Service Managers**

- SysV (init.d, chkconfig, etc.)
- Upstart (Ubuntu, Debian, etc.)

**Supported Operating Systems**
The following are supported and verified through test-kitchen automated integration testing.

- Centos
- Ubuntu

**Default Service Managers**

Unless otherwise specified in the **service_factory** global config, the default service manager is **SysV**, and
others are selected conditionally based on the distribution and version.

You can customize these defaults by adjusting the 'platform_map' node attribute, described below.


# Requirements

Cookbooks:: [unix_bin](http://community.opscode.com/cookbooks/service_factory) , [resource_masher](http://community.opscode.com/cookbooks/resource_masher) , [run_action_now](http://community.opscode.com/cookbooks/run_action_now)

Resource attributes:: `service_desc` , `exec` , `run_user` , `run_group`


# Simple Examples (More coming soon..)

*There is a full attribute listing towards end of README.*

** Basic service (required elements) **

    service_factory "my_service" do
      service_desc "My Service"
      exec "/opt/myapp/bin/run.sh"
      run_user "nobody"
      run_group "nobody"
      action :create                  # can also :enable and :start here, use array
    end
    
** Service with arguments or environment variables **

    service_factory "my_service" do
      service_desc "My Service"
      exec "/opt/myapp/bin/run.sh"
      exec_args "--port 1234"         # can also be an array of strings
      env_variables({                 # variables must be in a hash
        :SERVICE_VARIABLE => "value"
      })
      run_user "nobody"
      run_group "nobody"
      action :create
    end
    
** Forked service **

It's really import to set the proper flag if the service forks.
(Meaning that the script you're calling returns immediately and the service runs in the background.)

    service_factory "my_service" do
      service_desc "My Service"
      exec "/opt/myapp/bin/run.sh"
      exec_forks true
      pid_file "/opt/myapp/var/run/myapp.pid"
      run_user "nobody"
      run_group "nobody"
      action :create
    end
    
** Notifications **

The service_factory resource can receive all standard service signals. It also creates a stock service resource you can notify as well.

    some_resource "abc" do
      notifies :start, "service_factory[my_service]"
    end
    
    some_resource "abc" do
      notifies :start, "service[my_service]"
    end


# Resource Documentation

**RESOURCE ACTIONS**

    :create , :delete , :start , :stop , :restart , :enable , :disable

**Note:** You can also use a standard Chef service resource to manage the service once created.

**RESOURCE ATTRIBUTES**

    --------------------------------------------------------------------------------------
    :attribute       = default
        description (type)
    --------------------------------------------------------------------------------------

    :service_name
        Simple name of service. Defaults to resource name. (/^[a-z0-9_]+$/i)

    :service_desc
        Short description of service. (Required)

    :run_user
        Name or id of user to run service under. (Required)

    :run_group
        Name or id of group to run service under. (Required)

    :exec
        Full path to executable binary. (Required)

    :exec_args      = ""
        Command line args to executable. (String or Array)

    :exec_umask     = "0027"
        umask set before execution

    :exec_forks     = false
        Does executable fork at startup? (Important)

    :process_name   = basename %{exec}
        Used to detect status and stop service.

    :kill_timeout   = 5
        Number of seconds to wait before killing at stop/shutdown.

    :before_start   = ""
        Shell commands to run before starting service.

    :after_start    = ""
        Shell commands to run after starting service.

    :before_stop    = ""
        Shell commands to run before stopping service.

    :after_stop     = ""
        Shell commands to run after stopping service.

    :base_path      = ""
        Prefix to FHS paths.
        Ex. "/srv/myapp" => "/srv/myapp/etc/"

    :var_subpath    = ( %{run_user} == 'root'  ?  %{run_group}  :  %{service_name} )
        Suffix added to var directories.
        Ex. "myapp" => "/var/run/myapp/appname.pid"

    :lock_file      = %{base_path}/var/lock/subsys/%{service_name}
        Full path to lock file.

    :log_file       = %{base_path}/var/log/%{var_subpath}/%{service_name}.log
        Full path to log file.

    :log_what       = :none
        What service output should be logged. (:std_out  :std_err  :std_all  :none)

    :pid_file {base_path}/var/run/{var_subpath}/{service_name}.pid
        Full path to pid file.

    :create_pid     = %{exec_forks}  ?  false  :  true
        If true the factory creates a pid file, otherwise the daemon should create it.

    :env_variables  = Hash.new
        Shell environment variables to be exported into service

    :path_variables = Hash.new
        Additional variables injectable into path strings.


# Recipes

This cookbook only provides LWRPs, no recipes are included.


# Attributes

The following default node attributes govern the platform selection.
You may customize the operation by appending/overwriting these in your node configuration.

- `default["service_factory"]["platform_map"]["default"] = "init"`
- `default["service_factory"]["platform_map"]["ubuntu"]["default"] = "upstart"`


# Test-Kitchen

This package is **test-kitchen** enabled and automatically tested against:

- CentOS 5 and 6
- Ubuntu 10 and 12

A successful test appears as follows:

    -----> Running bats test suite
           1..6
           ok 1 non-forked service
           ok 2 forked service
           ok 3 sighup restart (non-forked)
           ok 4 sighup restart (forked)
           ok 5 nobody service
           ok 6 deleted service
           Finished verifying <default-ubuntu-1004> (1m18.10s).

Tested system service provided by [Unix Mock Service Daemon](https://github.com/org-binbab/unix_service_mock_daemon)


# Development and Maintenance

* Found a bug?
* Need some help?
* Have a suggestion?
* Want to contribute?

Please visit: [code.binbab.org](http://code.binbab.org)


# Authors and License

  * Author:: BinaryBabel OSS (<projects@binarybabel.org>)
  * Copyright:: 2013 `sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931`
  * License:: Apache License, Version 2.0

----

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
