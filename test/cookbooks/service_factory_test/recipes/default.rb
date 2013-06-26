#
# Cookbook Name:: service_factory_test
# Recipe:: default
#

unix_binaries do
  install %w{ nc wc egrep }
end

fts_basepath = "/opt/factory_test_service"
fts_script   = "#{fts_basepath}/fts.sh"

directory fts_basepath do
  action :create
  owner "root"
  group "root"
  mode 0777
end

cookbook_file fts_script do
  source "factory_test_service.sh"
  owner "root"
  group "root"
  mode 0755
end

service_manager = node[:service_factory][:provider]
unless service_manager
  service_manager = value_for_platform(node[:service_factory][:platform_map].to_hash)
end

file "#{fts_basepath}/fts.manager" do
  content service_manager
  owner "root"
  group "root"
  mode 0755
end

# Related tests:
#   Ensure output to log.
#   Ensure no parent PID.
#   Ensure PID file created.
#   Ensure hook execution.
#   Reload by propper handling of SIGHUP.
service_factory "fts_nofork" do
  action [ :create, :disable ]
  service_desc "Test Service"
  exec fts_script
  pid_file "#{fts_script}.pid"
  log_what :std_all
  run_user "root"
  run_group "root"
  supports :reload => true
  before_start "echo -n A1 >> #{fts_script}.a1b"
  after_start  "echo -n B2 >> #{fts_script}.a1b"
  before_stop  "echo -n C3 >> #{fts_script}.a1b"
  after_stop   "echo -n D4 >> #{fts_script}.a1b"
end

# Related tests:
#   Ensure PID forked.
#   Passing of command line args.
#   Ensure hook execution.
#   Reload by propper handling of SIGHUP.
service_factory "fts_fork" do
  action [ :create, :disable ]
  service_desc "Test Service (fork)"
  exec fts_script
  exec_args [ "--fork" ]
  exec_forks true
  pid_file "#{fts_script}.pid"
  run_user "root"
  run_group "root"
  supports :reload => true
  before_start "echo -n A1 >> #{fts_script}.a1b"
  after_start  "echo -n B2 >> #{fts_script}.a1b"
  before_stop  "echo -n C3 >> #{fts_script}.a1b"
  after_stop   "echo -n D4 >> #{fts_script}.a1b"
end

# Related tests:
#   Reload should cause restart.
service_factory "fts_huprestart" do
  action [ :create, :disable ]
  service_desc "Test Service (sighup restart)"
  exec fts_script
  exec_args [ "--no-reload" ]
  pid_file "#{fts_script}.pid"
  log_what :std_all
  run_user "root"
  run_group "root"
end

# Related tests:
#   Reload should cause restart.
service_factory "fts_huprestart_fork" do
  action [ :create, :disable ]
  service_desc "Test Service (sighup restart, fork)"
  exec fts_script
  exec_args [ "--fork", "--no-reload" ]
  exec_forks true
  pid_file "#{fts_script}.pid"
  run_user "root"
  run_group "root"
end

# Related tests:
#   Running under non-root user.
service_factory "fts_nobody" do
  action [ :create, :disable ]
  service_desc "Test Service (nobody user)"
  exec fts_script
  pid_file "#{fts_script}.pid.nobody"
  run_user "nobody"
  run_group "root"  # nobody group is not consistent accross systems
end

# Related tests:
#   Service can be deleted
service_factory "fts_delete" do
  action [ :create, :delete ]
  service_desc "Test Service (delete)"
  exec fts_script
  pid_file "#{fts_script}.pid"
  run_user "root"
  run_group "root"
end
