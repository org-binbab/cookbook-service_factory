#
# Cookbook Name:: service_factory
# Resource:: default
#
# Author:: BinaryBabel OSS (<projects@binarybabel.org>)
# Homepage:: http://www.binarybabel.org
# License:: Apache License, Version 2.0
#
# For bugs, docs, updates:
#
#     http://code.binbab.org
#
# Copyright 2013 sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931
#  
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#  
#     http://www.apache.org/licenses/LICENSE-2.0
#  
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def initialize(name, run_context=nil)
  super

  # Define stock service resource so that notifications can be sent to it directly.
  begin
    run_context.resource_collection.find(:service => name)
  rescue ::Chef::Exceptions::ResourceNotFound
    run_context.resource_collection.insert(::Chef::Resource::Service.new(name, run_context))
  end
end

actions :create, :delete, :start, :stop, :restart, :enable, :disable
default_action :create

attribute :service_name, :kind_of => String, :regex => /^[a-z0-9_]+$/i, :name_attribute => true
attribute :service_desc, :kind_of => String, :required => true

attribute :exec, :kind_of => String, :regex => /^[\/%]/, :required => true
attribute :exec_args, :kind_of => [ String, Array ], :default => ""
attribute :exec_umask, :kind_of => String, :default => "0027"
attribute :exec_forks, :kind_of => [ TrueClass, FalseClass ], :default => false

attribute :process_name, :kind_of => String, :default => nil
attribute :kill_timeout, :kind_of => Integer, :default => 5

attribute :before_start, :kind_of => String, :default => ""
attribute :after_start, :kind_of => String, :default => ""

attribute :before_stop, :kind_of => String, :default => ""
attribute :after_stop, :kind_of => String, :default => ""

attribute :base_path, :kind_of => String, :default => ""
attribute :var_subpath, :kind_of => String, :default => nil

attribute :lock_file, :kind_of => String, :default => "%{base_path}/var/lock/subsys/%{service_name}"
attribute :log_file, :kind_of => String, :default => "%{base_path}/var/log/%{var_subpath}/%{service_name}.log"
attribute :log_what, :equal_to => [ :std_out, :std_err, :std_all, :none ], :default => :none
attribute :pid_file, :kind_of => String, :default => "%{base_path}/var/run/%{var_subpath}/%{service_name}.pid"
attribute :create_pid, :kind_of => [ TrueClass, FalseClass ], :default => nil

attribute :run_user, :kind_of => String, :required => true
attribute :run_group, :kind_of => String, :required => true

attribute :env_variables, :kind_of => Hash, :default => Hash.new
attribute :path_variables, :kind_of => Hash, :default => Hash.new
