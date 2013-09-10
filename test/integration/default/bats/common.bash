
################################################################################
## CONFIGURATION ##
################################################################################

PORT=1234
BIN_TEST_USER="fts_user"
BIN_TEST_STRING="Soundslikefunonabun"
PID_FILE="/opt/factory_test_service/fts.sh.pid"
MGR_FILE="/opt/factory_test_service/fts.manager"
A1B_FILE="/opt/factory_test_service/fts.sh.a1b"

################################################################################
## HELPER FUNCTIONS ##
################################################################################

function bin_status_raw() {
  nc localhost ${1:-$PORT}
}

function bin_status() {
  prt=$PORT
  raw=""

  while [ $# -gt 0 ] ; do
    case $1 in
      -r)
        shift
        raw="$1"
        ;;
      -p)
        shift
        [ "$1" -gt 0 ] && PORT=$1
        ;;
      *)
        echo "ERROR: Invalid option passed to bin_status. ($1)" 1>&2
        exit 1
        ;;
    esac
    shift
  done

  if [ -n "$raw" ] ; then
    echo $raw
  else
    for i in 1 2 3 ; do
      raw="$(bin_status_raw)" || true
      [ -n "$raw" ] && break || true
      sleep 2
    done

    echo "DEBUG: $raw" 1>&2

    [ -z "$raw" ] || echo -n "$raw"
    [ -n "$raw" ]
  fi
}

function bin_timestamp() {
  bin_status -r "$1" | head -n1 | cut -d' ' -f2
}

function bin_ppid() {
  bin_status -r "$1" | head -n1 | cut -d' ' -f3
}

function bin_pid() {
  bin_status -r "$1" | head -n1 | cut -d' ' -f4
}

function bin_user() {
  bin_status -r "$1" | head -n1 | cut -d' ' -f5
}

function bin_loadcount() {
  bin_status -r "$1" | head -n1 | cut -d' ' -f6
}

function svc_status() {
  oscmd_status $1
}

function svc_start() {
  oscmd_start $1
  sleep 4
}

function svc_stop() {
  oscmd_stop $1
  sleep 4
}

function svc_restart() {
  oscmd_restart $1
  sleep 4
}

function svc_reload() {
  oscmd_reload $1
  sleep 4
}

function svc_list() {
  oscmd_list | egrep ^fts_ | egrep -v _auto
}

# Notes are not TAP compliant, but provides much needed debug info.
LAST_NOTE=""
function note() {
  [ -n "$LAST_NOTE" ] && echo "[+] PASS" && echo
  [ -n "$1" ] && echo ">>> $1"
  LAST_NOTE="$1"
}

function setup() {
  # Stop all fts_* sevices (excluding auto-started)
  while read -r service ; do
    [[ "$(oscmd_status $service)" =~ "$status_stopped" ]] || oscmd_stop $service 2> /dev/null || true
  done <<< "$(svc_list)"
  rm "$PID_FILE" &> /dev/null || true
}

function teardown() {
  [ -n "$LAST_NOTE" ] && echo "[!] FAIL" && echo || true
  echo "Leftover processes:"
  echo "--------------------------------------------------------"
  if ps h o user,pid,command -C fts.sh ; then
    killall -g fts.sh &> /dev/null || true
    sleep 2
    #killall nc &> /dev/null || true
  else
    echo "NONE"
  fi
  echo "--------------------------------------------------------"
}

################################################################################
## INCLUDED CONFIGURATION ##
################################################################################

SERVICE_MANAGER="$(cat $MGR_FILE 2> /dev/null)"
load "config_${SERVICE_MANAGER}"
