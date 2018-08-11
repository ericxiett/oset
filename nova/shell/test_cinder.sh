#!/bin/bash
DATES=$(date "+%Y-%m-%d")

#Test Cinder API

#stop cinder-api ,create volume
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop apache2&&systemctl status apache2"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create 10 testvol10g${i}"|tee -a /tmp/cinder-api.${DATES}.log
done

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep testvol10g
#start cinder-api
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start apache2&&systemctl status apache2"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_delete testvol10g${i}"|tee -a /tmp/cinder-api.${DATES}.log
done


salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep testvol10g


#Test cinder scheduler
#stop cinder-scheduler ,create volume
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop cinder-scheduler&&systemctl status cinder-scheduler"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
 for j in $(seq 5 -1 1);do
   salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create 10 testvol10gstop${i}_${j}"|tee -a /tmp/cinder-api.${DATES}.log
 done
done

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep -E "testvol10gstop._."
#start cinder-scheduler
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start cinder-scheduler&&systemctl status cinder-scheduler"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
 for j in $(seq 5 -1 1);do
   salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create 10 testvol10gstop${i}_${j}"|tee -a /tmp/cinder-api.${DATES}.log
 done
done

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep -E "testvol10gstart._."

#delete vm
vol_list=$(salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep testvol10gs|sed s/[[:space:]]//g|cut -d"|" -f2)

for i in ${vol_list};
do
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_delete ${i}"
done


##Test cinder-volume

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm testcindervolumevm 1"|tee -a /tmp/cinder-api.${DATES}.log
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create 10 testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log

for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop cinder-volume&&systemctl status cinder-volume"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "add_volume testcindervolumevm testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "remove_volume testcindervolumevm testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log
done


for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start cinder-volume&&systemctl status cinder-volume"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "add_volume testcindervolumevm testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log
sleep 3
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "remove_volume testcindervolumevm testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log
done

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm testcindervolumevm"|tee -a /tmp/cinder-api.${DATES}.log
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_delete testcindervolumedisk"|tee -a /tmp/cinder-api.${DATES}.log