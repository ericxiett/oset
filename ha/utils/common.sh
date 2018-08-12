#!/usr/bin/env bash

set -ex

DATE_INFO=`date "+%Y-%m-%d %H:%M:%S"`

# Common functions
# log_info()
# result_info()

log_info()
{
    echo -e "${DATE_INFO},$@" >>/tmp/hatest_detailed.log
}

result_info()
{
    echo -e "${DATE_INFO},$@" >>/tmp/oset_ha_result.log
}
