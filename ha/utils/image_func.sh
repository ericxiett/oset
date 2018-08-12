#!/usr/bin/env bash

set -e

DATES=$(date "+%Y-%m-%d")

openrc()
{
    export OS_IDENTITY_API_VERSION=3
    export OS_AUTH_URL=http://10.200.0.20:35357/v3
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_NAME=admin
    export OS_TENANT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=vjYXTG6vptMNweIx
    export OS_REGION_NAME=RegionOne
    export OS_INTERFACE=internal
    export OS_ENDPOINT_TYPE="internal"
    export OS_CACERT="/etc/ssl/certs/ca-certificates.crt"
}

# Function list
# create_image(): Create a new image
# list_images(): List images
# delete_image(): Delete image

create_image()
{
    openrc
    openstack image create --file $1 --disk-format qcow2 --container-format bare $2 | tee -a /tmp/hatest_detailed.log
}

list_images()
{
    openrc
    openstack image list | tee -a /tmp/hatest_detailed.log
}

delete_image()
{
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
