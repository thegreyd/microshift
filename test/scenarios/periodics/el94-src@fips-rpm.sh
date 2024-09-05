#!/bin/bash

# Sourced from scenario.sh and uses functions defined there. 

scenario_create_vms() {
    [[ "${UNAME_M}" =~ aarch64 ]] && { record_junit "setup" "scenario_create_vms" "SKIPPED"; exit 0; }

    prepare_kickstart host1 kickstart-liveimg.ks.template "" true
    launch_vm host1 rhel-9.4-microshift-source-isolated "" "" "" "" "" "1"
}

scenario_remove_vms() {
    [[ "${UNAME_M}" =~ aarch64 ]] && { echo "Only x86_64 architecture is supported with FIPS";  exit 0; }

    remove_vm host1
}

scenario_run_tests() {
    [[ "${UNAME_M}" =~ aarch64 ]] && { echo "Only x86_64 architecture is supported with FIPS"; exit 0; }

    run_tests host1 suites/fips/
}
