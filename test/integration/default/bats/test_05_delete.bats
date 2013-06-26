#!/usr/bin/env bats

load common

################################################################################
## DELETED SERVICE TEST ##
################################################################################

@test "deleted service" {
  SERVICE="fts_delete"

  note "Should not show in list."
    [ "$(svc_list | grep fts_delete | wc -l)" -eq 0 ]

  note "Log directory should still exist."
    [ -e "/var/log/fts_delete" ]

  note  # all done
}
