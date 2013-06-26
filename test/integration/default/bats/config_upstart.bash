status_running="start/running"
status_stopped="stop/waiting"

function oscmd_status() {
  /sbin/initctl status $1
}

function oscmd_start() {
  /sbin/initctl start $1
}

function oscmd_stop() {
  /sbin/initctl stop $1
}

function oscmd_restart() {
  /sbin/initctl restart $1
}

function oscmd_reload() {
  /sbin/initctl reload $1
}

function oscmd_list() {
  for f in /etc/init/fts_*.conf ; do
    basename $f .conf
  done
}
