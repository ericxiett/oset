#!/bin/bash
set -e

CURRENT_DIR="$(cd "$(dirname $0)" && pwd)"
CONFIG_FILE="${1:-allin}"
LOOP_NUM="${2:-5}"
for i in $(seq 0 "$LOOP_NUM"); do
    echo $i
    $CURRENT_DIR/neutron-test.sh $CONFIG_FILE
    if [ -e 'clear.sh' && -f 'clear.sh' ]; then 
        echo "Clean up left overs"
        . clear.sh
    fi
    sleep 60
done

