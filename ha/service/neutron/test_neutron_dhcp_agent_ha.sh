#!/bin/bash
#Test Nova Conductor

#pre para
DATES=$(date "+%Y-%m-%d")
times=$1
image_name="centos72x86_64"
exec_node="ctl01.inspurcloud.com"

#create_flavor
f_name="2C_2G_40G_dhcp_agent"    
vcpu="2"
mem="2048"
dsize="40"

for j in $(seq 1 ${times});do
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_create ${f_name} ${vcpu} ${mem} ${dsize}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log

#create_network
net_name="neutron_dhcp_net"
result=$(salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}"|grep -E '\| id|ACTIVE'|sed s/[[:space:]]//g)
echo "create network result:${result}"
#create subnet
subnet_name="sub_dhcp_agent_net"
cidr="192.168.100.0/24"
gw="192.168.100.254"  
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "subnet_create ${net_name} ${subnet_name} ${cidr} ${gw}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log

#create_vm
#create_vm_net five para,vm_name    vm_num   net_id    image_name    f_name
vm_num="1"
vm_name="neutrondhcpvm"

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log

sleep 60

#stop neutron-dhcp-agent ,reboot vm
for i in $(seq 3 -1 1);do
echo "stop gtw0${i}.inspurcloud.com neutron-dhcp-agent"
salt "gtw0${i}.inspurcloud.com" service.stop "neutron-dhcp-agent"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log
salt "gtw0${i}.inspurcloud.com" service.status "neutron-dhcp-agent"|tee -a /tmp/neutron-dhcp-agentr.${DATES}.log
sleep 10
salt "exec_node" cmd.script salt://ha_test/vm_func.sh "reboot_vm ${vm_name}"|tee -a /tmp/nova-conductor.${DATES}.log
sleep 15

done


#start neutron-dhcp-agent ,reboot vm
for i in $(seq 3 -1 1);do
echo "stop gtw0${i}.inspurcloud.com neutron-dhcp-agent"
salt "gtw0${i}.inspurcloud.com" service.start "neutron-dhcp-agent"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log
salt "gtw0${i}.inspurcloud.com" service.status "neutron-dhcp-agent"|tee -a /tmp/neutron-dhcp-agentr.${DATES}.log
sleep 10
salt "exec_node" cmd.script salt://ha_test/vm_func.sh "reboot_vm ${vm_name}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log
sleep 15

done


#delelet test dhcp vm
echo "Delete vm ${vm_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log

#delete flavor
echo "Delete flavor ${f_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_delete ${f_name}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log
#delete network
echo "Delete network ${net_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}"|tee -a /tmp/neutron-dhcp-agent.${DATES}.log