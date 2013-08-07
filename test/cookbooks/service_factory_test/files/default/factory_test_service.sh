#!/bin/bash
#
#  service_daemon.sh
#  ----------------------------------------------------------------------
#  Copyright 2013 sha1(OWNER) = df334a7237f10846a0ca302bd323e35ee1463931

#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
#   implied. See the License for the specific language governing
#   permissions and limitations under the License.
#  ----------------------------------------------------------------------

VERSION="0.1.1"
RELEASE="2013-08-06"

#  The latest version of this script, along with any documentation,
#  source code, and bug/feature management is available at:
#
#    http://code.binbab.org
#
#  ----------------------------------------------------------------------
#  This script acts as a unix service simulate. It has the ability to
#  track start/stop/reload actions in order to evalute the operation
#  of a wrapper or service management platform.
#
#  USAGE:
#    See "./service_daemon.sh --help" for more information.
#  ----------------------------------------------------------------------

#########################################################################
###### CONFIGURATION ####################################################

TEST_STRING="Soundslikefunonabun"
PORT=1234

###### END CONFIG #######################################################
#########################################################################

START_USER=$(whoami)
START_TIME=$(date +%s)
START_PID=$$
RELOAD_COUNTER=0
PARENT_PID="-1"
SUB_PID="-1"
FORK=0
RELOAD=1

function usage {
  echo
  echo ">>> UNIX SERVICE MOCK DAEMON, ver ${VERSION}"
  echo
  echo "Usage: $(basename $0) OPTIONS"
  echo
  echo "Default port: ${PORT}"
  echo
  echo "Response format:"
  echo "  TEST_STRING START_TIME PARENT_PID START_PID START_USER RELOAD_COUNTER"
  echo
  echo "Example response:"
  echo "  $TEST_STRING $START_TIME $PARENT_PID $START_PID $START_USER $RELOAD_COUNTER"
  echo
  echo "Available options:"
  echo "  --fork              Fork and return immediately"
  echo "  --no-reload         Exit on reload (SIGHUP)"
  echo "  --port PORT         Listen on alternate port"
  echo
  exit 1
}

function kill_sub {
  [ $SUB_PID -gt 0 ] && kill $SUB_PID &> /dev/null
}

function on_reload {
  echo "Received SIGHUP."
  RELOAD_COUNTER=$(( $RELOAD_COUNTER + 1 ))
  if [ $RELOAD -ne 1 ] ; then
    kill_sub
    exit 0
  fi
}

function cleanup {
  kill_sub
  exit 0
}

trap on_reload SIGHUP
trap cleanup SIGINT SIGTERM

while [ $# -gt 0 ] ; do
  case $1 in
    --fork)
      FORK=1
      ;;
    --no-reload)
      RELOAD=0
      ;;
    --port)
      shift
      [ "$1" -gt 0 ] && PORT=$1
      ;;
    --ppid)
      shift
      [ "$1" -gt 0 ] && PARENT_PID=$1
      ;;
    *)
      usage
      ;;
  esac
  shift
done

if [ $FORK -eq 1 ] ; then
  RELOAD_ARG=""
  [ $RELOAD -ne 1 ] && RELOAD_ARG="--no-reload"
  $0 --ppid $START_PID --port $PORT $RELOAD_ARG &
  PID=$!
  PID_FILE="$0.pid"
  echo $PID > $PID_FILE
  disown $PID
else
  echo "Started at $START_TIME by $START_USER with pid $START_PID using port $PORT"

  while true ; do
    echo "$TEST_STRING $START_TIME $PARENT_PID $START_PID $START_USER $RELOAD_COUNTER" | nc -lv $PORT &
    SUB_PID=$!
    wait
    EXIT_CODE=$?
    echo "Loop exit, code $EXIT_CODE."
    if [ $EXIT_CODE -gt 128 ] ; then
      # Trapped signal.
      kill_sub
    else
      [ $EXIT_CODE -eq 0 ] || exit 1
    fi
    sleep 1
  done
fi
