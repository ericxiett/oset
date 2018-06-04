#!/bin/bash
#Create rally task trends report
if [ $# -lt 3 ] 
    then 
        echo -e "Warning:The script require at least three parameters."
        echo "#########################################################################"
        echo "Usage: sh $0 scenarios_name uuid1 uuid2 uuid3 ..." 
        echo -e "Example: sh $0 create-and-delete-network a5df599c-48a3-489b-bd93-76eff1be5b83 0d53754f-7e76-4c7e-bbc3-1083b12c78c8\n"
        echo "#########################################################################"

        exit 1
fi

DATES=$(date "+%Y-%m-%d")
count=1
param=""
scenarios=$1
shift

while [ "$#" -ge "1" ];do
    echo "task uuid parameter $count is $1"
    let count=count+1
    param=${param}" "${1}
    shift
done
#/root/.bashrc add: alias rally='docker run -v /var/lib/rally_container:/home/rally/data xrally/xrally-openstack'
source /root/.bashrc

rally task trends --tasks ${param} --out /home/rally/data/result/${scenarios}-trends-${DATES}.html
  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.1.15-beta/nv.d3.min.css#http://cdn.bootcss.com/nvd3/1.1.15-beta/nv.d3.css#g'  /var/lib/rally_container/result/${scenarios}-trends-${DATES}.html
  sed -i 's#https://ajax.googleapis.com/ajax/libs/angularjs/1.3.3/angular.min.js#http://cdn.bootcss.com/angular.js/1.3.3/angular.min.js#g' /var/lib/rally_container/result/${scenarios}-trends-${DATES}.html
  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/d3/3.4.13/d3.min.js#http://cdn.bootcss.com/d3/3.4.13/d3.min.js#g' /var/lib/rally_container/result/${scenarios}-trends-${DATES}.html
  sed -i 's#https://cdnjs.cloudflare.com/ajax/libs/nvd3/1.1.15-beta/nv.d3.min.js#http://cdn.bootcss.com/nvd3/1.1.15-beta/nv.d3.min.js#g' /var/lib/rally_container/result/${scenarios}-trends-${DATES}.html
echo "Create trends ${scenarios}-trends-${DATES}.html successful"
