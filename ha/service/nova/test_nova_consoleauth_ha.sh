#!/bin/bash
#Test Nova Consoleauth

#pre para
times=$1
image_name="centos72x86_64"
exec_node="ctl01.inspurcloud.com"

#create_flavor
f_name="2C_2G_40G_nova_consoleauth"    
vcpu="2"
mem="2048"
dsize="40"

for j in $(seq 1 ${times});do
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_create ${f_name} ${vcpu} ${mem} ${dsize}"|tee -a /tmp/nova-consoleauth.${DATES}.log

#create_network
net_name="nova_consoleauth_net"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}"|tee -a /tmp/nova-consoleauth.${DATES}.log
#create subnet
subnet_name="sub_nova_consoleauth_net"
cidr="192.168.100.0/24"
gw="192.168.100.254"  
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "subnet_create ${net_name} ${subnet_name} ${cidr} ${gw}"|tee -a /tmp/nova-consoleauth.${DATES}.log

#create_vm
#create_vm_net five para,vm_name    vm_num   net_id    image_name    f_name
vm_num="1"
vm_name="novaconsoleauthvm"

salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "create_vm_net ${vm_name} ${vm_num} ${net_name} ${image_name} ${f_name}"|tee -a /tmp/nova-api.${DATES}.log

sleep 60
#stop nova-consoleauth ,consoleauth vm
for i in $(seq 5 -1 1);do
echo "stop ctl0${i}.inspurcloud.com nova-consoleauth"
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-consoleauth"|tee -a /tmp/nova-consoleauth.${DATES}.log
sleep 10
url=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "console_vm ${vm_name}" --out=json|grep stdout|cut -d'"' -f4)

if [ "${url}" == "" ];then
    echo "ctl0${i}.inspurcloud.com ${vm_name} console disable.ERROR"|tee -a /tmp/nova-consoleauth.${DATES}.log
else
 r_code=$(curl -o /dev/null -s -w "%{http_code}" ${url})	
 if [ "${r_code}" != '200' ];then
	echo "ctl0${i}.inspurcloud.com ${vm_name} console disable.ERROR"|tee -a /tmp/nova-consoleauth.${DATES}.log
 else
    echo "ctl0${i}.inspurcloud.com ${vm_name} console enable.Yes"|tee -a /tmp/nova-consoleauth.${DATES}.log	
 fi
fi
done


#start nova-consoleauth,consoleauth vm
for i in $(seq 5 -1 1);do
echo "start ctl0${i}.inspurcloud.com nova-consoleauth"	
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-consoleauth"|tee -a /tmp/nova-consoleauth.${DATES}.log
sleep 10
url=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "console_vm ${vm_name}" --out=json|grep stdout|cut -d'"' -f4)

if [ "${url}" == "" ];then
    echo "ctl0${i}.inspurcloud.com ${vm_name} console disable.ERROR"|tee -a /tmp/nova-consoleauth.${DATES}.log
else
 r_code=$(curl -o /dev/null -s -w "%{http_code}" ${url})	
 if [ "${r_code}" != '200' ];then
	echo "ctl0${i}.inspurcloud.com ${vm_name} console disable.ERROR"|tee -a /tmp/nova-consoleauth.${DATES}.log
 else
    echo "ctl0${i}.inspurcloud.com ${vm_name} console enable.Yes"|tee -a /tmp/nova-consoleauth.${DATES}.log	
 fi
fi
done

#delelet test console vm
echo "Delete vm ${vm_name}"
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm ${vm_name}"|tee -a /tmp/nova-consoleauth.${DATES}.log

#delete flavor
echo "Delete flavor ${f_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "flavor_delete ${f_name}"|tee -a /tmp/nova-consoleauth.${DATES}.log
#delete network
echo "Delete network ${net_name}"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}"|tee -a /tmp/nova-consoleauth.${DATES}.log
done