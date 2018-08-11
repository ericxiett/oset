#!/bin/bash
DATES=$(date "+%Y-%m-%d")

#Test Cinder Scheduler
times=$1
exec_node="ctl01.inspurcloud.com"
vol_name="volcinderscheduler"
vol_size="10"

for n in $(seq 1 ${times});do
#stop cinder-scheduler ,create volume
for i in $(seq 5 -1 1);do
  salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop cinder-scheduler&&systemctl status cinder-scheduler"|tee -a /tmp/cinder-scheduler.${DATES}.log
  sleep 3
  for j in $(seq 5 -1 1);do
     salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create ${vol_size} stop_${vol_name}${i}_${j}"|tee -a /tmp/cinder-scheduler.${DATES}.log
  done
done

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep ${vol_name}
#start cinder-scheduler
for i in $(seq 5 -1 1);do
  salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start cinder-scheduler&&systemctl status cinder-scheduler"|tee -a /tmp/cinder-scheduler.${DATES}.log
  for j in $(seq 5 -1 1);do
     salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_create ${vol_size} start_${vol_name}${i}_${j}"|tee -a /tmp/cinder-scheduler.${DATES}.log
  done
done


salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep ${vol_name}

#delete vm
vol_list=$(salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_list"|grep ${vol_name}|sed s/[[:space:]]//g|cut -d"|" -f2)

for i in ${vol_list};
do
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "volume_delete ${i}"
done

done