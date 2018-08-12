#!/bin/bash
#Test neutron l3 agent

#pre para
DATES=$(date "+%Y-%m-%d")
times=$1
exec_node="ctl01.inspurcloud.com"
vr_name="l3vrouter"

for j in $(seq 1 ${times});do
for i in $(seq 3 -1 1);do
echo "stop gtw0${i}.inspurcloud.com neutron-l3-agent"
salt "gtw0${i}.inspurcloud.com" service.stop "neutron-l3-agent"|tee -a /tmp/neutron-l3-agent.${DATES}.log
salt "gtw0${i}.inspurcloud.com" service.status "neutron-l3-agent"|tee -a /tmp/neutron-l3-agent.${DATES}.log
sleep 10
echo "create vroute"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "route_create ${vr_name}"|tee -a /tmp/neutron-l3-agent.${DATES}.log
sleep 3
done

for i in $(seq 3 -1 1);do
echo "start gtw0${i}.inspurcloud.com neutron-l3-agent"
salt "gtw0${i}.inspurcloud.com" service.start "neutron-l3-agent"|tee -a /tmp/neutron-l3-agent.${DATES}.log
salt "gtw0${i}.inspurcloud.com" service.status "neutron-l3-agent"|tee -a /tmp/neutron-l3-agent.${DATES}.log
sleep 10
echo "delete vroute"
salt "${exec_node}" cmd.script salt://ha_test/vm_func.sh "route_delete ${vr_name}"|tee -a /tmp/neutron-l3-agent.${DATES}.log
sleep 3
done

done