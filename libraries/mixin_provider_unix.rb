#
# Cookbook Name:: service_factory
# Library:: mixin_provider_unix
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

require 'chef/exceptions'
require 'chef/provider'
require 'chef/resource'

class Chef
  class Provider
    class ServiceFactory
      module Mixin
        module Unix

          def service_config
            if @service_config.nil?
              # Default var_subpath.
              # Use the group name (unless it's root), otherwise the service name.
              unless @service.var_subpath
                @service.var_subpath(
                    case
                      when @service.run_group && @service.run_group != "root"
                        @service.run_group
                      else
                        @service.service_name
                    end
                )
              end

              # Default create_pid flag.
              # Unless otherwise specified, create only if not forking.
              unless @service.create_pid != nil
                @service.create_pid(@service.exec_forks ? false : true)
              end
            end

            super
          end  # /service_config

          protected

          def create_dir(path, opts = nil)
            dir = nil
            dir_name = "#{service_config.service_name} required dirs"

            begin
              dir = run_context.resource_collection.find(:directory => dir_name)
            rescue ::Chef::Exceptions::ResourceNotFound
              dir = directory dir_name do
                action :nothing
                owner service_config.run_user
                group service_config.run_group
              end
            end

            dir.path(path)
            dir.mode(0775)
            dir.recursive(false)

            unless opts.nil?
              opts.each do |k,v|
                dir.send(k.to_s, v)
              end
            end

            dir.run_action(:create)
          end

          def create_dir_if_missing(path, opts)
            unless ::File.exists?(path)
              create_dir(path, opts)
            end
          end

          def unix_path_prep
            # Create standard var sub-directories if under a base path other than the root filesystem.
            base_path = service_config.base_path
            if base_path.to_s.match('^/[a-z]')  # not empty and absolute
              [
                  "",
                  "/var",
                  "/var/lock",
                  "/var/lock/subsys",
                  "/var/log",
                  "/var/run",
              ].each do |subdir|
                create_dir("#{base_path}#{subdir}")
              end
            end

            # Create any missing directories necessary to create the pid or log file.

            [
                ::File::dirname(service_config.pid_file),
                ::File::dirname(service_config.log_file),
            ].each do |path|
              create_dir_if_missing(path, :recursive => true)
            end

            # Ensure pid directory is writable (in case we didn't create it).
            # But only if we're certain it's dedicated to this service.
            if !service_config.exec_forks && service_config.create_pid && service_config.pid_file.match("^/var/run/#{service_config.var_subpath}/")
              create_dir(::File::dirname(service_config.pid_file))
            end

            # Create (and ensure writable) the log file.
            if !service_config.exec_forks && service_config.log_file.match("^/var/log/#{service_config.var_subpath}/")
              log_file = file service_config.log_file do
                owner service_config.run_user
                group service_config.run_group
                mode 0775
                action :nothing
              end
              log_file.run_action(:create)
            end
          end  # /unix_path_prep

        end
      end
    end
  end
end
