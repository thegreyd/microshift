#!/bin/bash

# Sourced from scenario.sh and uses functions defined there.

scenario_create_vms() {
    # The y-1 ostree image will be fetched from the cache as it is not built
    # as part of the bootc image build procedure
    prepare_kickstart host1 kickstart.ks.template "rhel-9.4-microshift-4.${PREVIOUS_MINOR_VERSION}"
    launch_vm host1 rhel-9.4
}

scenario_remove_vms() {
    remove_vm host1
}

scenario_run_tests() {
    run_tests host1 \
        --variable "TARGET_REF:rhel94-bootc-source-ostree-parent" \
        --variable "BOOTC_REGISTRY:${BOOTC_REGISTRY_URL}" \
        suites/upgrade/upgrade-successful-bootc.robot
}
