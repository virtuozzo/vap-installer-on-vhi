#!/bin/bash


TOKEN="$hosts_token"
TOKEN="${TOKEN,,}"
RESOLVER_IP="$resolver_ip"
PRIVATE_IP="$private_ip"
PUBLIC_IP="$public_ip"
INFRA1_INTERNAL_IP="$infra1_internal_ip"

function log(){
    echo "$(date "+%a %b %d %H:%M:%S.%N %Y") $@"
}

wait_resolvers(){
    log "Wait resolver start"
    local attempts=17280
    for i in $( seq $attempts ); do
        log "Attempt $i / $attempts"
        local responce=$(curl http://${RESOLVER_IP}/vap_metadata 2>/dev/null)
        domain=$(jq -r .domain <<< $responce)
        log "$responce"
        [[ -z "$domain" || "$domain" == "null" ]] || {
            return 0
        }
        sleep 20
    done
    return 255
}


get_cmd(){
    log "Get hot add command"
    local attempts=300

    for i in $( seq $attempts ); do
        log "Attempt $i / $attempts"
        local responce=$(curl -ksL "http://app.${domain}/JElastic/administration/cluster/rest/getaddhostcmd?session=${TOKEN}&appid=cluster" 2>/dev/null)
        log "${responce}"
        local result=$(jq -r .result <<< $responce)
        if [[ "$result" == "0" ]]; then
            cmd=$(jq -r .value <<< $responce)
            [[ -z $cmd ]] || return 0
        fi
        sleep 10
    done
    exit 255
}

get_licens_info(){
    log "Get hot add command"
    local attempts=300
    for i in $( seq $attempts ); do
        log "Attempt $i / $attempts"
        local responce=$(curl "http://jca.${domain}/1.0/security/license/rest/getlicenseinfo?appid=cluster&skipServicesValidation=true&session=${TOKEN}")
        log $responce;
        local status=$(jq -r .status  <<<$responce)
        [[ "$status" == "ACTIVE" ]] && return 0
        sleep 10
    done
    return 255
}

make_swap(){
    local dev=$1
    log "Make swap"
    if ! grep -q swap /etc/fstab; then
        [[ -b  /dev/${dev} ]] && {
            mkswap /dev/${dev}
            unset UUID
            eval $(blkid /dev/${dev} -o export)
            echo "UUID=$UUID swap            swap    defaults        0       0" >> /etc/fstab
            swapon -a
        }
    fi
}

make_vz(){
    local part="/dev/${1}"
    local dev="${part%%[0-9]}"
    local part_number="${part: -1:1}"
    local mountpoint=$2
    
    log "Make $mountpoint"
    if ! grep -qw $mountpoint /etc/fstab; then
        [[ -b  ${part} ]] && {
            local services=(
                pfcached.service
                prl-disp.service
                vz-motd.service
                vz-swappiness-wa.service
                vz.service
                vz-motd.timer
                pfcached-mount.service  
            )
            for i in ${services[@]}; do
                log "Stop $i"
                systemctl stop $i
            done
            mountpoint -q /vz/pfcache && umount /vz/pfcache
            /bin/lsblk -o NAME | \
                /bin/awk '($1 ~ /^ploop[[:digit:]]+/){print}' | \
            while read tmp; do
                /usr/sbin/ploop umount -d /dev/$tmp
            done
            
            rm -rf /vz/*
            growpart $dev $part_number
            e2fsck -yf $part
            resize2fs $part
            local UUID=$(uuidgen)
            tune2fs $part -U $UUID

            echo "UUID=$UUID $mountpoint ext4 defaults,noatime,lazytime 1 2" >> /etc/fstab
            mount $mountpoint

            for i in $(ls -1 /vz/ | grep -vw vz); do rm -rf /vz/${i}; done
            mv /vz/vz/* /vz/
            rm -rf /vz/vz

            for i in ${services[@]}; do
                log "Restart $i"
                systemctl restart $i
            done

        }
    fi
}

configure_disks(){
    set -x
    local parts=( $(sudo lsblk -o NAME,HCTL,SIZE,MOUNTPOINT | grep -Eo "(v|s)d." | uniq -u) )
    local parts2=( $(lsblk -l -o NAME,MOUNTPOINT  | grep -E '^(s|v)d.[0-2]' | awk '{ if(!$2) print $1}') )
    for part in ${parts2[@]}; do
        flag=$(parted /dev/${part%?} --script print | awk "{ if (\$1 == \"${part: -1:1}\") print \$NF}")
        [[ "$flag" == "bios_grub" ]] || parts=( ${parts[@]} $part )
    done
    IFS=$'\n' parts=($(sort <<<"${parts[*]}"))
    unset IFS
    
    local a=1
    for i in ${parts[@]}; do
        echo ">>>> $i"
        if (( $a == 1 )); then
            make_swap $i
        elif (( $a == 2 )); then
            make_vz $i /vz
        fi
        a=$(( $a +1 ))
    done
    set +x
}

function generatePassword(){
    local PASSWORD_LENGTH=15;
    local CHARS="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";
    local PASSWORD;
    local n=0;
    while [ "${n:=1}" -le "$PASSWORD_LENGTH" ] ; do
        PASSWORD="$PASSWORD${CHARS:$(($RANDOM%${#CHARS})):1}"
        let n+=1
    done
    echo $PASSWORD;
}

main(){
    for i in $(vzlist  -a1 | grep -E '[[:blank:]]3[0-9]{2}([[:blank:]]|$)'); do
        vzctl destroy $i;
    done
    systemctl stop docker
    systemctl disable docker
    [[ -z "$INFRA1_INTERNAL_IP" ]] || {
        iptables -I INPUT -s $INFRA1_INTERNAL_IP -j ACCEPT
        iptables -I FORWARD -s 192.168.128.0/17 -j ACCEPT
        status="--status INFRASTRUCTURE_NODE"
    }

    configure_disks || return 255;
    wait_resolvers || return $?
    get_cmd || return $?
    get_licens_info || return $?

    PASSWORD="$(generatePassword)"

    for i in {1..5}; do
        echo "Add host. Attempt $i"
        eval "$cmd --force true --install_vz false --ip ${PRIVATE_IP} --externalip ${PUBLIC_IP} $status --password $PASSWORD" && break
        sleep 60
    done

}

main >> /var/log/install.log 2>&1
