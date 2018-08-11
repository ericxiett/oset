#!/bin/bash
DATES=$(date "+%Y-%m-%d")
#####nova function
#create_vm()   :openstack server create
#delete_vm()   :openstack server delete
#list_vm()     :openstack server list
#stop_vm()     :openstack server stop
#start_vm()    :openstack server start
#migrate_vm()  :nova live-migration 
#console_vm()  :openstack console url show  
#show_vm()     :openstack server show     
#add_volume()  :openstack server  add volume
#remove_volume() :openstack server  remove volume

#####cinder function 
#volume_create() :openstack volume create 
#volume_delete() :openstack volume delete 
#volume_list()   :openstack volume list 

#server info
flavor_name="2_2G_40G"
image_name="centos72x86_64"
net_id="f18c7bca-a95e-43e3-be23-20cbcae19b8a"
min_num=1
#max_num=1
vm_name="testvm"${DATES}

#network info

#log info
log_info ()
{
DATE_N=`date "+%Y-%m-%d %H:%M:%S"`
USER_N=`whoami`
echo "${DATE_N},$@" >>/tmp/testHA_log.log

}

openrc(){
    export OS_IDENTITY_API_VERSION=3
    export OS_AUTH_URL=http://10.200.0.20:35357/v3
    export OS_PROJECT_DOMAIN_NAME=Default
    export OS_USER_DOMAIN_NAME=Default
    export OS_PROJECT_NAME=admin
    export OS_TENANT_NAME=admin
    export OS_USERNAME=admin
    export OS_PASSWORD=vjYXTG6vptMNweIx
    export OS_REGION_NAME=RegionOne
    export OS_INTERFACE=internal
    export OS_ENDPOINT_TYPE="internal"
    export OS_CACERT="/etc/ssl/certs/ca-certificates.crt"
}

create_vm()
{
vm_name=$1
vm_num=$2
openrc
log_info "create vm:${vm_name}"
openstack server create --flavor ${flavor_name} --image ${image_name}   --nic net-id=${net_id}  \
  --availability-zone nova \
  --min ${min_num} --max ${vm_num}  ${vm_name} |tee -a /tmp/testHA_log.log
}

delete_vm()
{
name_vm=$1
openrc
openstack server delete  ${name_vm} |tee -a /tmp/testHA_log.log
}


list_vm()
{
#innode=$1
echo "List all servers"|tee -a /tmp/testHA_log.log
openrc
openstack server list |tee -a /tmp/testHA_log.log
}

stop_vm()
{
vm_name=$1
openrc
echo "stop vm ${vm_name}">>/tmp/testHA_log.log
openstack server stop ${vm_name}|tee -a /tmp/testHA_log.log
}

start_vm()
{
vm_name=$1
openrc
echo "start vm ${vm_name}">>/tmp/testHA_log.log
openstack server start ${vm_name}|tee -a /tmp/testHA_log.log
}

migrate_vm()
{
#
vm_name=$1
openrc
echo "migrate server"|tee -a /tmp/testHA_log.log
#openstack server migrate  ${vm_name}
nova live-migration  ${vm_name}
}

console_vm()
{
vm_name=$1
openrc
#|grep vnc_auto|sed s/[[:space:]]//g|cut -d"|" -f3
openstack console url show ${vm_name}|grep vnc_auto|sed s/[[:space:]]//g|cut -d"|" -f3 
}

show_vm()
{
vm_name=$1
openrc
#|grep vnc_auto|sed s/[[:space:]]//g|cut -d"|" -f3
openstack server show ${vm_name}
}

add_volume()
{
vm_name=$1
vol_name=$2
openrc
#openstack server  add volume <server> <volume>
openstack server  add volume ${vm_name} ${vol_name} 
}


remove_volume()
{
vm_name=$1
vol_name=$2
openrc
#openstack server remove volume [-h] <server> <volume>
openstack server  remove volume ${vm_name} ${vol_name} 
}

####cinder()
volume_create()
{
    vol_size=$1
    vol_name=$2

    openrc

    openstack volume create --size ${vol_size} ${vol_name}
}

volume_delete()
{
    vol_name=$1

    openrc

    openstack volume delete --size ${vol_name}
}

volume_list()
{
    openrc

    openstack volume list
}

#neuton
network_create()
{
 net_name=$1   
 openrc
 openstack network create ${net_name}    
}

subnet_create()
{
 net_name=$1
 subnet_name=$2   
 openrc
 neutron subnet-create --name ${subnet_name} --dns-nameserver 114.114.114.114 --gateway 1.1.1.254 ${net_name} 1.1.1.0/24   
}

main()
{
func_name=$1
    

if [ ${func_name} == "create_vm" ];then
   para_name=$2
   max_num=$3  
   ${func_name} ${para_name} ${max_num}
elif [ ${func_name} == "list_vm" ] || [ ${func_name} == "volume_list" ];then
   ${func_name}
elif [ ${func_name} == "volume_create" ];then
   v_size=$2
   v_name=$3
   ${func_name} ${v_size} ${v_name}
elif [ ${func_name} == "add_volume" ] || [ ${func_name} == "remove_volume" ];then
   vm_name=$2
   vol_name=$3
   ${func_name} ${vm_name} ${vol_name}      
else
   para_name=$2 
   ${func_name} ${para_name}   
fi    

}

main $@