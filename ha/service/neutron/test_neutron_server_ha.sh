#!/bin/bash
DATES=$(date "+%Y-%m-%d")

#Test Neutron API
times=$1
net_name="net_neutronserver"

for j in $(seq 1 ${times});do
for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl stop neutron-server&&systemctl status neutron-server"|tee -a /tmp/neutron.${DATES}.log
sleep 3
result=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "network_create ${net_name}${i}"|grep ACTIVE)
echo "create network result:${result}"
if [ -z "${result}" ];then
	echo "ctl0${i}.inspurcloud.com create network failure"|tee -a /tmp/neutron.${DATES}.log
else
    echo "ctl0${i}.inspurcloud.com create network successful" |tee -a /tmp/neutron.${DATES}.log	
fi	


done

for i in $(seq 5 -1 1);do
salt "ctl0${i}.inspurcloud.com" cmd.run "systemctl start neutron-server&&systemctl status neutron-server"|tee -a /tmp/neutron.${DATES}.log
sleep 3
result=$(salt "ctl0${i}.inspurcloud.com" cmd.script salt://ha_test/vm_func.sh "network_delete ${net_name}${i}" --out=json|grep stderr|cut -d'"' -f4)
echo "delete network result:${result}"
if [ -z "${result}" ];then
	echo "ctl0${i}.inspurcloud.com delete network successful"|tee -a /tmp/neutron.${DATES}.log
else
    echo "ctl0${i}.inspurcloud.com create network failure" |tee -a /tmp/neutron.${DATES}.log	
fi
done

done
