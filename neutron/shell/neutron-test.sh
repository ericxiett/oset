#!/bin/bash
#Execute rally scenarios task and create task report
if [ $# -lt 1 ] 
    then 
        echo -e "Warning:The script must have one parameters."
        echo "#########################################################################"
        echo "Usage: sh $0 (json or yaml file name)" 
        echo -e "Example: sh $0 neutron-multiple-scenarios\n"
        echo "#########################################################################"

        exit 1
   fi  



TESTCASE=$1
ENVUUID="f40589d2-1b45-4c10-9bb1-753260f72796"
DATES=$(date "+%Y-%m-%d")

#/root/.bashrc add: alias rally='docker run -v /var/lib/rally_container:/home/rally/data xrally/xrally-openstack'
source /root/.bashrc


touch /var/lib/rally_container/result/${TESTCASE}.output
ARG_OPTS=
if [ -f /var/lib/rally_container/${TESTCASE}.json ]
then
   if [ -f /var/lib/rally_container/${TESTCASE}-args.json ]; then
       ARG_OPTS=" --task-args-file  /home/rally/data/${TESTCASE}-args.json"
   fi

   rally --debug --plugin-path /home/rally/data/plugins task start $ARG_OPTS /home/rally/data/${TESTCASE}.json  ${ENVUUID} |tee -a /var/lib/rally_container/result/${TESTCASE}.output
elif [ -f /var/lib/rally_container/${TESTCASE}.yaml ];then
   if [ -f /var/lib/rally_container/${TESTCASE}-args.yaml ]; then
       ARG_OPTS=" --task-args-file  /home/rally/data/${TESTCASE}-args.yaml"
   fi
   rally --debug --plugin-path /home/rally/data/plugins  task start /home/rally/data/${TESTCASE}.yaml ${ENVUUID} $ARG_OPTS  |tee -a /var/lib/rally_container/result/${TESTCASE}.output
else
   echo "${TESTCASE} test case not exists"
   exit 1
fi


task_uuid=$(grep -E [0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12} /var/lib/rally_container/result/${TESTCASE}.output |tail -n 1|cut -d ' ' -f 4)
touch /var/lib/rally_container/result/${TESTCASE}-${task_uuid}-${DATES}
if [ -z "$task_uuid" ]
then
   echo "obtain task uuid failure"
else
   echo "create result directory"
   mkdir -p "/var/lib/rally_container/result/$task_uuid"
   chmod 766 "/var/lib/rally_container/result/$task_uuid" 
   chown 65500:65500  "/var/lib/rally_container/result/$task_uuid"
   rally task report ${task_uuid} --out "/home/rally/data/result/${task_uuid}/${TESTCASE}.html"

  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.1.15-beta/nv.d3.min.css#http://cdn.bootcss.com/nvd3/1.1.15-beta/nv.d3.css#g'  /var/lib/rally_container/result/${task_uuid}/${TESTCASE}.html
  sed -i 's#https://ajax.googleapis.com/ajax/libs/angularjs/1.3.3/angular.min.js#http://cdn.bootcss.com/angular.js/1.3.3/angular.min.js#g' /var/lib/rally_container/result/${task_uuid}/${TESTCASE}.html
  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/d3/3.4.13/d3.min.js#http://cdn.bootcss.com/d3/3.4.13/d3.min.js#g' /var/lib/rally_container/result/${task_uuid}/${TESTCASE}.html
  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.1.15-beta/nv.d3.min.js#http://cdn.bootcss.com/nvd3/1.1.15-beta/nv.d3.min.js#g' /var/lib/rally_container/result/${task_uuid}/${TESTCASE}.html
  echo "The ${TESTCASE} running successfull!"
fi
