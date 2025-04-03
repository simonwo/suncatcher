#!/bin/bash
set -euo pipefail
IFS=$'\n\t'
set -x

TARGET_MAC='c6:71:04:44:e3:41'

arp-scan -T $TARGET_MAC -I en0 --quiet --localnet | grep $TARGET_MAC | cut -f1 | tee ip.txt | sort -u
