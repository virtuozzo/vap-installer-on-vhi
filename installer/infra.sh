#!/bin/bash

version=$(cat /etc/jelastic/infra_version)

if [[ ! -z "$proxy" ]]; then
    param_proxy="--proxy $proxy"
    param_le="--lets_encrypt NO"
fi

if [[ ! -z "$nameserver" ]]; then
    param_ns="--nameserver $nameserver"
fi

cp /var/lib/jelastic/get_jelastic_containers.sh /tmp/

cd /root
curl ${param_proxy} https://dot.jelastic.com/download/selfinstall/installer/jelastic_installer-${version}.sh > /root/jelastic_installer.sh;
vap_install_link_file=/root/vap_install_link
[[ -s /root/jelastic_installer.sh ]] && \
    bash -n /root/jelastic_installer.sh && \
    sed -i "/${vap_install_link_file##*/}/d" /root/.bashrc || {
        echo > $vap_install_link_file
        sed -i "/${vap_install_link_file##*/}/d" /root/.bashrc
        message="\\033[1;31m\033[1mLooks like the installation script can't be downloaded or is broken.\\033[0m\\033[0;39m"
        echo -e "$message" | tee -a $vap_install_link_file
        echo | tee -a $vap_install_link_file
        echo "cat $vap_install_link_file" >> /root/.bashrc
}

bash /root/jelastic_installer.sh \
--webinstaller_password $webinstaller_password \
--network 192.168.128.0/17 \
--firstip 192.168.129.1 \
--ipaddress $resolver1_ip,$resolver2_ip \
--hosts_token $hosts_token \
--lets_encrypt TRY \
--containers "zookeeper,jelastic-db,jelcore:2,gate:2:2,jbilling:2,jstatistic:2,hcore:2,awakener,uploader,puppet,resolver:2,webgate:2,msa,backuper,jms" \
--infra2_ip $infra2_internal_ip \
--disks_to_mount "1:swap,2:/vap-platform,3:/vz" \
--hd_requirement_warning "NO" \
--docker_cache_folder "/vap-platform/docker" $param_proxy $param_le $param_ns \
--skiparping >> /var/log/install.log 2>&1
