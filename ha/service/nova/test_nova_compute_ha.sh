#!/bin/bash
#Test Nova Compute

#pre para
DATES=$(date "+%Y-%m-%d")
times=$1
image_name="centos72x86_64"
exec_node="ctl01.inspurcloud.com"

#create_flavor
f_name="2C_2G_40G_nova_compute"    
vcpu="2"
mem="2048"
dsize="40"

for j in $(seq 1 ${times});do
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_create ${f_name} ${vcpu} ${mem} ${dsize}"|tee -a /tmp/nova-compute.${DATES}.log

#create_network
net_name="nova_compute_net"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}"|tee -a /tmp/nova-compute.${DATES}.log
#create subnet
subnet_name="sub_nova_compute_net"
cidr="192.168.200.0/24"
gw="192.168.200.254"  
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "subnet_create ${net_name} ${subnet_name} ${cidr} ${gw}"|tee -a /tmp/nova-compute.${DATES}.log

#create_vm
#create_vm_net five para,vm_name    vm_num   net_id    image_name    f_name
vm_num="1"
vm_name01="novacomputevm01"
vm_name02="novacomputevm02"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name01} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/nova-compute.${DATES}.log

sleep 60
#stop nova-compute ,create vm
vm_host=$(salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "show_vm ${vm_name01}"|grep hypervisor_hostname|cut -d"|" -f3|sed s/[[:space:]]//g)
echo "${vm_name01} running on ${vm_host}"
salt "${vm_host}" cmd.run "systemctl stop nova-compute&&systemctl status nova-compute"|tee -a /tmp/nova-compute.${DATES}.log

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name02} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/nova-compute.${DATES}.log

sleep 60

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "stop_vm ${vm_name01}"|tee -a /tmp/nova-compute.${DATES}.log
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "stop_vm ${vm_name02}"|tee -a /tmp/nova-compute.${DATES}.log

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "list_vm" |grep -E "novacomputevm0."|tee -a /tmp/nova-compute.${DATES}.log
salt "${vm_host}" cmd.run "systemctl start nova-compute&&systemctl status nova-compute"|tee -a /tmp/nova-compute.${DATES}.log
#
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "stop_vm ${vm_name01}"|tee -a /tmp/nova-compute.${DATES}.log

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name01}"|tee -a /tmp/nova-compute.${DATES}.log
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name02}"|tee -a /tmp/nova-compute.${DATES}.log

#delete flavor
echo "Delete flavor ${f_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_delete ${f_name}"|tee -a /tmp/nova-compute.${DATES}.log
#delete network
echo "Delete network ${net_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}"|tee -a /tmp/nova-compute.${DATES}.log
done