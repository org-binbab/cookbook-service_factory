#!/bin/bash

TEST_STRING="Soundslikefunonabun"
PORT=1234

START_USER=$(whoami)
START_TIME=$(date +%s)
START_PID=$$
RELOAD_COUNTER=0
PARENT_PID="-1"
SUB_PID="-1"
FORK=0
RELOAD=1

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
