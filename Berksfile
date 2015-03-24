source "http://api.berkshelf.com"

metadata

# Contains a fix for chef12
cookbook 'unix_bin', git: 'https://github.com/alejandrod/cookbook-unix_bin.git'
cookbook 'resource_masher'
cookbook 'run_action_now'

group :integration do
  cookbook 'service_factory_test', :path => './test/cookbooks/service_factory_test'
end
