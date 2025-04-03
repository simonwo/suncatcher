#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

SOLAR_IP_ADDRESS=$(cat ip.txt)

curl -s "http://${SOLAR_IP_ADDRESS}/solar_api/v1/GetPowerFlowRealtimeData.fcgi" |
	jq '.Body.Data.Site + {"Timestamp": .Head.Timestamp}' |
	sqlite-utils insert solar.db site -
