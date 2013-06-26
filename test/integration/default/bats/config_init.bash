status_running="is running"
status_stopped="is stopped"

function oscmd_status() {
  /etc/init.d/$1 status
}

function oscmd_start() {
  /etc/init.d/$1 start
}

function oscmd_stop() {
  /etc/init.d/$1 stop
}

function oscmd_restart() {
  /etc/init.d/$1 restart
}

function oscmd_reload() {
  /etc/init.d/$1 reload
}

function oscmd_list() {
  for f in /etc/init.d/* ; do
    [ -x "$f" ] && basename $f
  done
}
