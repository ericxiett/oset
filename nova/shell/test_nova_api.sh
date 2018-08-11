#!/bin/bash
DATES=$(date "+%Y-%m-%d")

#Test Nova API
#stop nova-api ,create vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-api"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
#salt 'ctl01*' cmd.run 'openstack --os-identity-api-version 3 \
#--os-username admin --os-password vjYXTG6vptMNweIx --os-project-name admin \ 
#--os-auth-url  http://10.200.0.20:35357/v3 --os-project-domain-name Default \ 
#--os-region-name RegionOne --os-cacert /etc/ssl/certs/ca-certificates.crt server list';
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm vmctl0${i} 1"|tee -a /tmp/nova-api.${DATES}.log
done


#start nova-api,delete vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-api"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm vmctl0${i}"|tee -a /tmp/nova-api.${DATES}.log
done


#Test Nova Conductor

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm testmigrate 1"|tee -a /tmp/nova-api.${DATES}.log
#stop nova-conductor ,migrate vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-conductor"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "migrate_vm testmigrate"|tee -a /tmp/nova-api.${DATES}.log
done


#start nova-conductor,migrate vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-conductor"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "migrate_vm testmigrate"|tee -a /tmp/nova-api.${DATES}.log
done

#delelet test migrate vm
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm testmigrate"|tee -a /tmp/nova-api.${DATES}.log


#Test Nova Scheduler
#stop nova-scheduler ,create vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-scheduler"|tee -a /tmp/nova-api.${DATES}.log
sleep 20
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm ${i}scheduler 5"|tee -a /tmp/nova-api.${DATES}.log
done
#start nova-scheduler ,create vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-scheduler"|tee -a /tmp/nova-api.${DATES}.log
sleep 20
salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm ${i}scheduler 5"|tee -a /tmp/nova-api.${DATES}.log
done
#delete vm
#salt "ctl01.inspurcloud.com" cmd.script salt://0809/createvm.sh "list_vm"|grep spt|cut -d" " -f10
#sed s/[[:space:]]//g|cut -d"|" -f2
#vm_lists=$(salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "list_vm"|grep scheduler|cut -d" " -f10)
vm_lists=$(salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "list_vm"|grep scheduler|sed s/[[:space:]]//g|cut -d"|" -f2)
for i in ${vm_lists};
do
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm ${i}"|tee -a /tmp/nova-api.${DATES}.log
done

#Test Nova consoleauth

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm testconsoleauth 1"|tee -a /tmp/nova-api.${DATES}.log
#stop nova-consoleauth ,consoleauth vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop nova-consoleauth"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
#salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "console_vm testconsoleauth"
#curl -o /dev/null -s -w "%{http_code}" https://10.200.0.50:6080/vnc_auto.html?token=eccae6a3-7b17-448f-8db9-c5f9a5226701
url=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "console_vm testconsoleauth" --out=json|grep stdout|cut -d'"' -f4)

if [ "${url}" == "" ];then
    echo "ctl0${i}.inspurcloud.com testconsoleauth console disable.ERROR"|tee -a /tmp/nova-api.${DATES}.log
else
 r_code=$(curl -o /dev/null -s -w "%{http_code}" ${url})	
 if [ ${r_code} != '200' ];then
	echo "ctl0${i}.inspurcloud.com testconsoleauth console disable.ERROR"|tee -a /tmp/nova-api.${DATES}.log
 else
    echo "ctl0${i}.inspurcloud.com testconsoleauth console enable.Yes"|tee -a /tmp/nova-api.${DATES}.log	
 fi
fi
done


#start nova-consoleauth,consoleauth vm
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start nova-consoleauth"|tee -a /tmp/nova-api.${DATES}.log
sleep 10
url=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "console_vm testconsoleauth" --out=json|grep stdout|cut -d'"' -f4)

if [ "${url}" == "" ];then
    echo "testconsoleauth console disable.ERROR"|tee -a /tmp/nova-api.${DATES}.log
else
 r_code=$(curl -o /dev/null -s -w "%{http_code}" ${url})	
 if [ ${r_code} != '200' ];then
	echo "ctl0${i}.inspurcloud.com testconsoleauth console disable.ERROR"|tee -a /tmp/nova-api.${DATES}.log
 else
    echo "ctl0${i}.inspurcloud.com testconsoleauth console enable.Yes"|tee -a /tmp/nova-api.${DATES}.log	
 fi
fi
done

#delelet test migrate vm
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "delete_vm testconsoleauth"|tee -a /tmp/nova-api.${DATES}.log


#Test Nova compute
#|grep hypervisor_hostname|cut -d"|" -f3|sed s/[[:space:]]//g
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm vm01compute 1"|tee -a /tmp/nova-api.${DATES}.log
sleep 10

vm_host=$(salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "show_vm vm01compute"|grep hypervisor_hostname|cut -d"|" -f3|sed s/[[:space:]]//g)

salt "${vm_host}" cmd.run "systemctl stop nova-compute&&systemctl status nova-compute"|tee -a /tmp/nova-api.${DATES}.log

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "create_vm vm02compute 1"|tee -a /tmp/nova-api.${DATES}.log
sleep 10

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "stop_vm vm01compute"|tee -a /tmp/nova-api.${DATES}.log
salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "stop_vm vm02compute"|tee -a /tmp/nova-api.${DATES}.log

salt "ctl01.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "list_vm" |grep -E "vm0.compute"|tee -a /tmp/nova-api.${DATES}.log