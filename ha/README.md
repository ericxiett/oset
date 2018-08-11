# HA tests

## Priciple of tests coding
1. 预置
2. 触发
3. 校验
4. 输出
5. 恢复

## 预置条件
OpenStack采用HA模式部署

## Directory layout
* service
* node
* rack
* switch
* pdu
* all

## Service Level HA tests

### Services list
* nova: nova-api, nova-conductor, nova-scheduler, nova-consoleauth
* cinder: cinder-api(apache2), cinder-scheduler, cinder-volume
* neutron: neutron-server, neutron-l3-agent, neutron-dhcp-agent, neutron-metadata-agent
* glance: glance-api
* keystone: apache2
* mysql
* rabbitmq
* keepalived
* haproxy

### Test cases

## Node Level HA tests

### Node list
* ctl

## Rack Level HA tests

### Rack list
no

## Switch Level HA tests

### Switch list
* Business TOR switch

## PDU Level HA tests

## ALL Level HA tests


