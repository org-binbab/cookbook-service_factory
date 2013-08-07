#
# Cookbook Name:: service_factory
# Library:: provider_init
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

%w{
  provider
  mixin_provider_unix
}.each do |req|
  require File.expand_path("#{req}.rb", File.dirname(__FILE__))
end

class Chef
  class Provider
    class ServiceFactoryProvider
      class Init < Generic

        include RunActionNow::Mixin
        include Chef::Provider::ServiceFactory::Mixin::Unix

        def install_service
          unix_path_prep  # from unix mixin

          # Requirements.
          run_action_now((
            unix_bin "chkconfig" do
              if platform?("debian")
                action :install
                package "chkconfig"
              end
            end
          ))

          # Create init.d script.
          run_action_now((
            template "/etc/init.d/#{service_config.service_name}" do
              action :create
              cookbook "service_factory"
              source "init.service.erb"
              owner "root"
              group "root"
              mode 0755
              variables(service_config.symbolize_keys)  # full service_config provided
            end
          ))

          # Add service via chkconfig.
          run_action_now((
            bash "chkconfig: /etc/init.d/#{service_config.service_name}" do
              user "root"
              group "root"
              cwd "/tmp"
              code <<-EOH
  /sbin/chkconfig --add #{service_config.service_name}
              EOH
              action :run
            end
           ))
        end  # /install_service

        def uninstall_service
          # Requirements.
          run_action_now((
            unix_bin "chkconfig"
           ))

          if ::File.exists?("/etc/init.d/#{service_config.service_name}")
            # Remove service via chkconfig.
            run_action_now((
              bash "chkconfig: /etc/init.d/#{service_config.service_name}" do
                user "root"
                group "root"
                cwd "/tmp"
                code <<-EOH
  /sbin/chkconfig --del #{service_config.service_name} || true
                EOH
                action :run
              end
            ))

            # Remove init.d script.
            run_action_now((
              file "/etc/init.d/#{service_config.service_name}" do
                action :delete
              end
            ))
          end

        end  # /uninstall_service

      end
    end
  end
end
