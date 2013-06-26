#!/usr/bin/env bats

load common

################################################################################
## FORKED SERVICE TEST ##
################################################################################

@test "forked service" {
  SERVICE="fts_fork"

  note "Should not be running."
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should be unresponsive."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note "Remove hook tracking file."
    [ ! -e "$A1B_FILE" ] || rm -v "$A1B_FILE"

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

  note "Ensure parent pid has exited."
    run kill -0 $bs_ppid 2> /dev/null
    [ "$status" -ne 0 ]

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

  note "Reload should maintain timestamp."
    bs="$(bin_status)"
    TIMESTAMP_RELOAD=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP_RELOAD" ]
    [ "$TIMESTAMP_RELOAD" -gt 0 ]
    [ "$TIMESTAMP_RELOAD" = "$TIMESTAMP" ]

  note "Reload should show in SIGHUP counter."
    [ "$(bin_loadcount $bs)" -eq 1 ]

  note "Stop and check status."
    svc_stop $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_stopped" ]]

  note "Port should not respond if processes were properly terminated."
    run bin_status_raw
    [ "$output" = "" ]
    [ "$status" -eq 1 ]

  note "Ensure all hooks executed."
    [ "$(cat $A1B_FILE)" = "A1B2C3D4" ]

  note  # all done
}
