#!/usr/bin/env bash

. ../../utils/common.sh

set -ex

echo "==START: test_ha_glance_api"

# Global variables
DATES=$(date "+%Y-%m-%d")
IMG_NAME="oset-cirros"

prepare_env()
{
    echo "====PREPARE: update cirros image"
    # NOTE: cirros image MUST be in /root at ctl01 node
    img_file=/root/cirros-0.3.5-x86_64-disk.img
    openrc
    salt "ctl01*" cmd.script salt://ha_test/image_func.sh "create_image $img_file $IMG_NAME"

    sleep 10
    result=`salt "ctl01*" cmd.script salt://ha_test/image_func.sh "list_images" | grep $IMG_NAME`
    if [ -z $result ]; then
        echo "Failed to create image"
        exit 1
    fi
}

validate()
{
    expected=$1
    # Call image list api to validate
    result=`salt "ctl01*" cmd.script salt://ha_test/image_func.sh "list_images" | grep $IMG_NAME`
    if [ $result != $expected ]; then
        log_info "test_ha_glance_api: validate failed, actual $result != expected $expected"
        return 1
    fi
    return 0
}

triage()
{
    
    for i in $(seq 5 -1 1);do
        salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-api"|tee -a /tmp/glance-api.${DATES}.log
        sleep 10
        validate
    done
}

echo "==END: test_ha_glance_api"
