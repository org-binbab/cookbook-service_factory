#!/usr/bin/env bats

load common

################################################################################
## NON-FORKED SERVICE TEST ##
################################################################################

@test "non-forked service" {
  SERVICE="fts_nofork"

  note "Should not be running."
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should be unresponsive."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note "Clear log file."
    LOGFILE="/var/log/$SERVICE/$SERVICE.log"
    cat /dev/null > $LOGFILE

  note "Remove hook tracking file."
    [ ! -e "$A1B_FILE" ] || rm -v "$A1B_FILE"

  note "Start and check status."
    svc_start $SERVICE
    run svc_status $SERVICE
    echo $output
    [[ $output =~ "$status_running" ]]

  note "Connect to service process."
    bs="$(bin_status)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note "Verify running as correct user."
    bs_user="$(bin_user $bs)"
    [ "$bs_user" = "$BIN_TEST_USER" ]

  note "Ensure empty parent pid (we didn't fork)."
    [ "$(bin_ppid $bs)" = "-1" ]

  note "Ensure PID file created."
    [ -e "$PID_FILE" ]
    [ "$(cat $PID_FILE)" = "$(bin_pid $bs)" ]

  note "Obtain timestamp."
    TIMESTAMP=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP" ]
    [ "$TIMESTAMP" -gt 0 ]

  note "Connect again, verify timestamp unchanged."
    [ "$(bin_timestamp)" = "$TIMESTAMP" ]

  note "Ensure log file (which we cleared) shows connection attempts."
    [ "$(cat $LOGFILE | wc -c)" -ne 0 ]
    [[ "$(tail -n50 $LOGFILE)" =~ "Connection from" ]]

  note "Request reload."
    svc_reload $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Reload should maintain timestamp."
    bs="$(bin_status)"
    TIMESTAMP_RELOAD=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP_RELOAD" ]
    [ "$TIMESTAMP_RELOAD" -gt 0 ]
    [ "$TIMESTAMP_RELOAD" = "$TIMESTAMP" ]

  note "Reload should show in SIGHUP counter."
    [ "$(bin_loadcount $bs)" -eq 1 ]

  note "Environment should include test variable."
    printf "$bs" | grep "TEST_VAR=1234 5678"

  note "Stop and check status."
    svc_stop $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should not respond if processes were properly terminated."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note "PID file should no longer exist."
    [ ! -e "$PID_FILE" ]

  note "Ensure all hooks executed."
    [ "$(cat $A1B_FILE)" = "A1B2C3D4" ]

  note  # all done
}
