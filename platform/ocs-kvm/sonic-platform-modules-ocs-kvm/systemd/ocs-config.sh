#!/bin/bash
# Loads the OCS domain configuration into CONFIG_DB at boot.
# Mirrors sonic-otn's otn-config.sh: DEVICE_METADATA (type/switch_type) from
# ocs-metadata.json, then the per-HwSKU OCS_PORT / OCS_CROSS_CONNECT tables.

PLATFORM=${PLATFORM:-`sonic-cfggen -d -v DEVICE_METADATA.localhost.platform`}
sonic-cfggen -j /usr/share/sonic/device/$PLATFORM/ocs-metadata.json --write-to-db
HWSKU=${HWSKU:-`sonic-cfggen -d -v DEVICE_METADATA.localhost.hwsku`}
sonic-cfggen -j /usr/share/sonic/device/$PLATFORM/$HWSKU/ocs_config.json --write-to-db
