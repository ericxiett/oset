#!/bin/bash
#Test Cinder Volume

#pre para
times=$1
image_name="centos72x86_64"
exec_node="ctl01.inspurcloud.com"

#volume
vol_name="volcindervolume"
vol_size="10"

#create_flavor
f_name="2C_2G_40G_cinder_volume"    
vcpu="2"
mem="2048"
dsize="40"

for j in $(seq 1 ${times});do
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_create ${f_name} ${vcpu} ${mem} ${dsize}"|tee -a /tmp/cinder_volume.${DATES}.log

#create_network
net_name="cinder_volume_net"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}"|tee -a /tmp/cinder_volume.${DATES}.log
#create subnet
subnet_name="sub_cinder_volume_net"
cidr="192.168.210.0/24"
gw="192.168.210.254"  
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "subnet_create ${net_name} ${subnet_name} ${cidr} ${gw}"|tee -a /tmp/cinder_volume.${DATES}.log

#create_vm
#create_vm_net five para,vm_name    vm_num   net_id    image_name    f_name
vm_num="1"
vm_name="cindervolumevm"

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/cinder_volume.${DATES}.log
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_create ${vol_size} ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
sleep 60

for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop cinder-volume&&systemctl status cinder-volume"|tee -a /tmp/cinder_volume.${DATES}.log
sleep 3
echo "add_volume ${vm_name} ${vol_name}"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "add_volume ${vm_name} ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
sleep 3
echo "remove_volume ${vm_name} ${vol_name}"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "remove_volume ${vm_name} ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
done


for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start cinder-volume&&systemctl status cinder-volume"|tee -a /tmp/cinder_volume.${DATES}.log
sleep 3
echo "add_volume ${vm_name} ${vol_name}"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "add_volume ${vm_name} ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
sleep 3
echo "remove_volume ${vm_name} ${vol_name}"
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "remove_volume ${vm_name} ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
done
#
echo "Delete vm ${vm_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name}"|tee -a /tmp/cinder_volume.${DATES}.log
echo "Delete volume ${vol_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "volume_delete ${vol_name}"|tee -a /tmp/cinder_volume.${DATES}.log
#delete flavor
echo "Delete flavor ${f_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_delete ${f_name}"|tee -a /tmp/cinder_volume.${DATES}.log
#delete network
echo "Delete network ${net_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}"|tee -a /tmp/cinder_volume.${DATES}.log
done