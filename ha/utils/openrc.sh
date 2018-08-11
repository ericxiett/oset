#!/bin/bash

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
