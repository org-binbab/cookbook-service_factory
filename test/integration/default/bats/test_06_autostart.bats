#!/usr/bin/env bats

load common

################################################################################
## AUTO-START SERVICE TEST ##
################################################################################

@test "default service" {
  SERVICE="fts_default_auto"
  PORT=1235

  note "Should be running on $PORT."
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Should be responsive."
    bs="$(bin_status -p $PORT)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note  # all done
}

@test "notify service_factory" {
  SERVICE="fts_notify1_auto"
  PORT=1236

  note "Should be running on $PORT."
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Should be responsive."
    bs="$(bin_status -p 1236)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note  # all done
}

@test "notify service" {
  SERVICE="fts_notify2_auto"
  PORT=1237

  note "Should be running on $PORT."
    run svc_status $SERVICE
    [[ $output =~ "$status_running" ]]

  note "Should be responsive."
    bs="$(bin_status -p 1237)"
    [[ "$bs" =~ "$BIN_TEST_STRING" ]]

  note  # all done
}
