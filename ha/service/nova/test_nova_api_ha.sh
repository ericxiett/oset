#!/bin/bash
#Test Nova API

#pre para
DATES=$(date "+%Y-%m-%d")
times=$1
image_name="centos72x86_64"
exec_node="ctl01.inspurcloud.com"

#create_flavor
f_name="2C_2G_40G_nova_api"    
vcpu="2"
mem="2048"
dsize="40"

for j in $(seq 1 ${times});do
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_create ${f_name} ${vcpu} ${mem} ${dsize}"|tee -a /tmp/nova-api.${DATES}.log

#create_network
net_name="nova_api_net"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}"|tee -a /tmp/nova-api.${DATES}.log
#create subnet
subnet_name="sub_nova_api_net"
cidr="192.168.200.0/24"
gw="192.168.200.254"  
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "subnet_create ${net_name} ${subnet_name} ${cidr} ${gw}"|tee -a /tmp/nova-api.${DATES}.log

#create_vm
#create_vm_net five para,vm_name    vm_num   net_id    image_name    f_name
vm_num="1"
vm_name="novaapivm"

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/nova-api.${DATES}.log

sleep 60
#stop nova-api ,create vm
for i in $(seq 5 -1 1);do
echo "stop ctl0${i}.inspurcloud.com nova-api"
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-api"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name}${i} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/nova-api.${DATES}.log
done


#start nova-api,delete vm
for i in $(seq 5 -1 1);do
echo "start ctl0${i}.inspurcloud.com nova-api"	
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-api"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name}${i}"|tee -a /tmp/nova-api.${DATES}.log
done

#delete flavor
echo "Delete flavor ${f_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_delete ${f_name}"|tee -a /tmp/nova-api.${DATES}.log
#delete network
echo "Delete network ${net_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}"|tee -a /tmp/nova-api.${DATES}.log
done