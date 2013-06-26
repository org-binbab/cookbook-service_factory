#
# Cookbook Name:: service_factory
# Library:: provider
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

require 'chef/provider'
require 'chef/resource'

class Chef
  class Provider
    class ServiceFactoryProvider
      class Generic < Chef::Provider

        def initialize(new_resource, run_context)
          super
          @service = new_resource.factory
          @service_config = nil
        end

        def load_current_resource

        end

        def whyrun_supported?
          false
          #TODO Review whyrun support.
        end

        def action_install
          converge_by("install service #{@new_resource}") do
            install_service
            Chef::Log.info("#{@new_resource} installed")
          end
        end

        def action_uninstall
          converge_by("delete service #{@new_resource}") do
            uninstall_service
            Chef::Log.info("#{@new_resource} uninstalled")
          end
        end

        def install_service
          raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :install"
        end

        def uninstall_service
          raise Chef::Exceptions::UnsupportedAction, "#{self.to_s} does not support :uninstall"
        end

        protected

        def service
          service_config
          @service
        end

        def service_config
          if @service_config.nil?
            # Generate conf mash.
            conf = @service.attribute_mash_formatted  # see "resource_masher" cookbook for details
            conf[:supports_reload] = @service.supports.has_key?(:reload) ? @service.supports[:reload] : false
            Chef::Log.debug("service #{@new_resource} config:")
            Chef::Log.debug(conf.to_yaml)
            @service_config = conf
          end

          @service_config
        end

      end
    end
  end
end

class Chef
  class Resource
    class ServiceFactoryProvider < Chef::Resource

      identity_attr :service_name
      provider_base Chef::Provider::ServiceFactoryProvider

      def initialize(name, run_context=nil)
        super
        @resource_name = :service_factory_provider
        @service_name = name
        @factory = nil
        @action = "nothing"
        @allowed_actions.push(:install, :uninstall)
      end

      def service_name(arg=nil)
        set_or_return(
            :service_name,
            arg,
            :kind_of => [ String ]
        )
      end

      def factory(arg=nil)
        set_or_return(
            :factory,
            arg,
            :kind_of => [ Chef::Resource::ServiceFactory ]
        )
      end

    end
  end
end
