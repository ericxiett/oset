#!/bin/bash
DATES=$(date "+%Y-%m-%d")

#Test Cinder API
times=$1
exec_node="ctl01.inspurcloud.com"
vol_name="volcinderapi"
vol_size="10"
for j in $(seq 1 ${times});do
#stop cinder-api ,create volume
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop apache2&&systemctl status apache2"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create ${vol_size} ${vol_name}${i}"|tee -a /tmp/cinder-api.${DATES}.log
done

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep ${vol_name}
#start cinder-api
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start apache2&&systemctl status apache2"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_delete ${vol_name}${i}"|tee -a /tmp/cinder-api.${DATES}.log
done


salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep testvol10g

done