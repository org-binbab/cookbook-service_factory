#!/usr/bin/env bats

load common

################################################################################
## SIGHUP RESTART (NON-FORKED SERVICE) TEST ##
################################################################################

@test "sighup restart (non-forked)" {
  SERVICE="fts_huprestart"

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

  note "Start and check status."
    svc_start $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Connect to service process."
    bs="$(bin_status)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note "Ensure empty parent pid (we didn't fork)."
    [ "$(bin_ppid $bs)" = "-1" ]

  note "Obtain timestamp."
    TIMESTAMP=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP" ]
    [ "$TIMESTAMP" -gt 0 ]

  note "Connect again, verify timestamp unchanged."
    [ "$(bin_timestamp)" = "$TIMESTAMP" ]

  note "Request reload."
    svc_reload $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Reload should show new timestamp."
    bs="$(bin_status)"
    TIMESTAMP_RELOAD=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP_RELOAD" ]
    [ "$TIMESTAMP_RELOAD" -gt 0 ]
    [ "$TIMESTAMP_RELOAD" -gt "$TIMESTAMP" ]

  note "Reload should show empty SIGHUP counter."
    [ "$(bin_loadcount $bs)" -eq 0 ]

  note "Stop and check status."
    svc_stop $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should not respond if processes were properly terminated."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note  # all done
}

################################################################################
## SIGHUP RESTART (FORKED SERVICE) TEST ##
################################################################################

@test "sighup restart (forked)" {
  SERVICE="fts_huprestart_fork"

  note "Should not be running."
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should be unresponsive."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note "Start and check status."
    svc_start $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Connect to service process."
    bs="$(bin_status)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note "Ensure non-empty parent pid (we forked)."
    bs_ppid="$(bin_ppid $bs)"
    [ "$bs_ppid" -gt 0 ]

  note "Obtain timestamp."
    TIMESTAMP=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP" ]
    [ "$TIMESTAMP" -gt 0 ]

  note "Connect again, verify timestamp unchanged."
    [ "$(bin_timestamp)" = "$TIMESTAMP" ]

  note "Request reload."
    svc_reload $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Reload should show new timestamp."
    bs="$(bin_status)"
    TIMESTAMP_RELOAD=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP_RELOAD" ]
    [ "$TIMESTAMP_RELOAD" -gt 0 ]
    [ "$TIMESTAMP_RELOAD" -gt "$TIMESTAMP" ]

  note "Reload should show empty SIGHUP counter."
    [ "$(bin_loadcount $bs)" -eq 0 ]

  note "Stop and check status."
    svc_stop $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should not respond if processes were properly terminated."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note  # all done
}
