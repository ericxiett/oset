#!/bin/bash
#Test ksystone

#pre para
DATES=$(date "+%Y-%m-%d")
times=$1

for j in $(seq 1 ${times});do
#stop apache2 ,project list
for i in $(seq 5 -1 1);do
echo "stop ctl0${i}.inspurcloud.com apache2"
salt "ctl0${i}.inspurcloud.com" service.stop "apache2"|tee -a /tmp/keystone.${DATES}.log
salt "ctl0${i}.inspurcloud.com" service.status "apache2"|tee -a /tmp/keystone.${DATES}.log
sleep 10
echo "ctl0${i}.inspurcloud.com stop apache2 project list"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "project_list"|tee -a /tmp/keystone.${DATES}.log
done



#start apache2 ,project list
for i in $(seq 5 -1 1);do
echo "start ctl0${i}.inspurcloud.com apache2"
salt "ctl0${i}.inspurcloud.com" service.start "apache2"|tee -a /tmp/keystone.${DATES}.log
salt "ctl0${i}.inspurcloud.com" service.status "apache2"|tee -a /tmp/keystone.${DATES}.log
sleep 10
echo "ctl0${i}.inspurcloud.com start apache2 project list"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "project_list"|tee -a /tmp/keystone.${DATES}.log
done

done