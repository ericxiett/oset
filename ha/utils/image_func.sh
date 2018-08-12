#!/usr/bin/env bash

. ./common.sh
. ./openrc.sh

set -ex

DATES=$(date "+%Y-%m-%d")

# Function list
# create_image(): Create a new image
# list_images(): List images
# delete_image(): Delete image

create_image()
{
    log_info "Create a new image"
    openrc
    openstack image create --file $1 --disk-format qcow2 --container-format bare $2 | tee -a /tmp/hatest_detailed.log
}

list_images()
{
    log_info "List images"
    openrc
    openstack image list | tee -a /tmp/hatest_detailed.log
}

delete_image()
{
    log_info "Delete image"
    openrc
    openstack image delete $1 | tee -a /tmp/hatest_detailed.log
}

main()
{
    func_name=$1

    if [ $func_name == "list_images" ]; then
        $func_name
    elif [ "create_image" == $func_name ];then
        img_file=$2
        img_name=$3
        $func_name $img_file $img_name
    elif [[ "delete_image" == $func_name ]]; then
        img_name=$2
        $func_name $img_name
    fi
}

main $@
