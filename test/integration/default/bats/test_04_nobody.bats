#!/usr/bin/env bats

load common

################################################################################
## NOBODY USER SERVICE TEST ##
################################################################################

@test "nobody service" {
  SERVICE="fts_nobody"

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

  note "Verify running as nobody user."
    bs_user="$(bin_user $bs)"
    [ "$bs_user" = "nobody" ]

  note "Obtain timestamp."
    TIMESTAMP=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP" ]
    [ "$TIMESTAMP" -gt 0 ]

  note "Connect again, verify timestamp unchanged."
    [ "$(bin_timestamp)" = "$TIMESTAMP" ]

  note "Request restart."
    svc_restart $SERVICE
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]
    
  note "Restart should show new timestamp."
    bs="$(bin_status)"
    TIMESTAMP_RESTART=$(bin_timestamp $bs)
    [ -n "$TIMESTAMP_RESTART" ]
    [ "$TIMESTAMP_RESTART" -gt 0 ]
    [ "$TIMESTAMP_RESTART" != "$TIMESTAMP" ]

  note "Restart should show same user."
    [ "$(bin_user $bs)" = "$bs_user" ]

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
