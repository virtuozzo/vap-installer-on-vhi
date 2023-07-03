#!/bin/bash

version=$(cat /etc/jelastic/infra_version)

cd /root
curl https://dot.jelastic.com/download/selfinstall/installer/jelastic_installer-${version}.sh > /root/jelastic_installer.sh;
bash /root/jelastic_installer.sh \
--webinstaller_password $webinstaller_password \
--network 192.168.128.0/17 \
--firstip 192.168.129.1 \
--ipaddress $resolver1_ip,$resolver2_ip \
--hosts_token $hosts_token \
--lets_encrypt TRY \
--containers "zookeeper,jelastic-db,jelcore:2,gate:2:2,jbilling:2,jstatistic:2,hcore:2,awakener,uploader,puppet,resolver:2,webgate:2,msa,backuper,zabbix" \
--infra2_ip $infra2_internal_ip \
--disks_to_mount "1:swap,2:/vap-platform,3:/vz" \
--hd_requirement_warning "NO" \
--docker_cache_folder "/vap-platform/docker" \
--skiparping >> /var/log/install.log 2>&1

