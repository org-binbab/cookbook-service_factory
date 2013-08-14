#
# Cookbook Name:: service_factory
# Provider:: default
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

include RunActionNow::Mixin

action :create do

  # Select provider.
  sub_provider_name = node[:service_factory][:provider]
  unless sub_provider_name
    #TODO This can be moved to the attributes file in Chef-11 forward.
    sub_provider_name = value_for_platform(node[:service_factory][:platform_map].to_hash)
    node.default["service_factory"]["provider"] = sub_provider_name
  end

  # Pass control to new provider.
  run_action_now((
    service_factory_provider new_resource.name do
      action :install
      factory new_resource
      provider sub_provider_name
    end
  ))

end

action :delete do

  # Select provider.
  sub_provider_name = node[:service_factory][:provider]
  unless sub_provider_name
    #TODO This can be moved to the attributes file in Chef-11 forward.
    sub_provider_name = value_for_platform(node[:service_factory][:platform_map].to_hash)
    node.default["service_factory"]["provider"] = sub_provider_name
  end

  # Pass control to new provider.
  run_action_now((
    service_factory_provider new_resource.name do
      action :uninstall
      factory new_resource
      provider sub_provider_name
    end
  ))

end

[ :start, :stop, :restart, :enable, :disable ].each do |svc_action|

  action svc_action do
    svc_name = new_resource.name
    svc = run_context.resource_collection.find(:service => svc_name)
    svc.run_action(svc_action)
  end

end
