#!/usr/bin/env bash

. ../../utils/common.sh

set -ex

echo "==START: test_ha_glance_api"

# Global variables
DATES=$(date "+%Y-%m-%d %H:%M:%S")
IMG_NAME="oset-cirros"
RED="\e[1;31m"
GREEN="\e[1;32m"
NC="\e[0m"

prepare_env()
{
    echo "====PREPARE: update cirros image"
    # NOTE: cirros image MUST be in /root at ctl01 node
    log_info "test_glance_api_ha(prepare_env): Create a new image"
    img_file=/root/cirros-0.3.5-x86_64-disk.img
    salt "ctl01*" cmd.script salt://ha_test/image_func.sh "create_image $img_file $IMG_NAME"
    sleep 10

#    result=`salt "ctl01*" cmd.script salt://ha_test/image_func.sh "list_images" | grep $IMG_NAME | grep active`
#    if [ -z '$result' ]; then
#        salt "ctl01*" cmd.script salt://ha_test/image_func.sh "create_image $img_file $IMG_NAME"
#        sleep 10
#        result=`salt "ctl01*" cmd.script salt://ha_test/image_func.sh "list_images" | grep $IMG_NAME | grep active`
#        if [ -z '$result' ]; then
#            echo "Failed to create image"
#            exit 1
#        fi
#    fi
}

validate()
{
    staging=$1
    expected=$2
    # Call image list api to validate
    log_info "test_glance_api_ha(validate): List images"
    result=`salt "ctl01*" cmd.script salt://ha_test/image_func.sh "list_images" | grep $IMG_NAME | awk -F'|' '{print $4}' | sed 's/[[:space:]]//g'`
    if [ -n $expected ] && [ $expected = $result ]; then
        log_info "test_ha_glance_api: $staging validate success!"
        return 0
    elif [ -z $expected ] && [ -z $result ]; then
        log_info "test_ha_glance_api: $staging validate success!"
        return 0
    else
        log_info "test_ha_glance_api: $staging validate failed, actual $result != expected $expected"
        return 1
    fi
}

clean_env()
{
    echo "====CLEAN: delete cirros image"
    log_info "test_glance_api_ha(clean_env): Delete image"
    salt "ctl01*" cmd.script salt://ha_test/image_func.sh "delete_image $IMG_NAME"
}

triage()
{
    # Stop api to test
    for i in $(seq 5 -1 1);do
        salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop glance-api"|tee -a /tmp/glance-api.${DATES}.log
        sleep 10
        if [ $i != 1 ]; then
            exp="active"
        else
            exp=""
        fi
        validate "stop-api" $exp
        if [ $? != 0 ]; then
            result_info "test_ha_glance_api FAILED"
            clean_env
            return
        fi
    done
    # Start api to test
    for i in $(seq 5 -1 1);do
        salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start glance-api"|tee -a /tmp/glance-api.${DATES}.log
        sleep 10
        validate "start api" "active"
        if [ $? != 0 ]; then
            result_info "test_ha_glance_api FAILED"
            clean_env
            return
        fi
    done
    result_info "test_ha_glance_api SUCCESS"
}


# Execute
# Default 1 if $1 is null
COUNT=${1:-1}
prepare_env
for i in $(seq 1 $COUNT)
do
    triage
done
clean_env

echo "==END: test_ha_glance_api"
