#!/bin/bash

echo "============= config-topology-init.sh start============="
PLATFORM=${PLATFORM:-`sonic-cfggen -H -v DEVICE_METADATA.localhost.platform`}
#Path to platform topology script
TOPOLOGY_SCRIPT_FILE="/usr/share/sonic/device/$PLATFORM/plugins/topology-init-script"
TOPOLOGY_SCRIPT_CONFIG="/usr/share/sonic/device/$PLATFORM/plugins/topology-config.json"
FACTORY_DEFAULT_HOOKS="/etc/config-setup/factory-default-hooks.d/"
COMMAND_GENERATE_SCRIPT_BGP="/usr/share/sonic/device/$PLATFORM/plugins/bgp-init-script"
COMMAND_GENERATE_SCRIPT_MGMT_INTF="/usr/share/sonic/device/$PLATFORM/plugins/mgmt-init-script"

# run given script
run_hook() {
    local script="$1"
    local script_param="$2"
    local exit_status=0

    if [ -f $script ]; then
        # Check hook for syntactical correctness before executing it
        /bin/bash -n $script $script_param
        exit_status=$?
        if [ "$exit_status" -eq 0 ]; then
            . $script $script_param
        fi
        exit_status=$?
    fi

    if [ -n "$exit_status" ] && [ "$exit_status" -ne 0 ]; then
        echo "$script returned non-zero exit status $exit_status"
    fi

    return $exit_status
}

mkdir -p ${FACTORY_DEFAULT_HOOKS}
chmod +x ${TOPOLOGY_SCRIPT_FILE} ${COMMAND_GENERATE_SCRIPT_BGP} ${COMMAND_GENERATE_SCRIPT_MGMT_INTF}

cp ${TOPOLOGY_SCRIPT_CONFIG} ${FACTORY_DEFAULT_HOOKS}
cp ${TOPOLOGY_SCRIPT_FILE} ${FACTORY_DEFAULT_HOOKS}

run_hook ${COMMAND_GENERATE_SCRIPT_BGP}
run_hook ${COMMAND_GENERATE_SCRIPT_MGMT_INTF}

echo "============= config-topology-init.sh end  ============="