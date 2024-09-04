#!/bin/bash

# Sourced from scenario.sh and uses functions defined there.

# Redefine network-related settings to use the dedicated network bridge
VM_BRIDGE_IP="$(get_vm_bridge_ip "${VM_MULTUS_NETWORK}")"
# shellcheck disable=SC2034  # used elsewhere
WEB_SERVER_URL="http://${VM_BRIDGE_IP}:${WEB_SERVER_PORT}"

scenario_create_vms() {
    prepare_kickstart host1 kickstart-bootc.ks.template rhel94-bootc-source-optionals
    # Two nics - one for macvlan, another for ipvlan (they cannot enslave the same interface)
    launch_vm host1 rhel94-bootc "${VM_MULTUS_NETWORK}" "" "" "" "2" "" "1"
}

scenario_remove_vms() {
    remove_vm host1
}

scenario_run_tests() {
    run_tests host1 suites/optional/
}
