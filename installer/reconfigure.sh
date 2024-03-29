#!/bin/bash

for i in flavors.json images.json infraFlavors.json keypairs.json storagePolicies.json subnets.json userFlavors.json; do
    [ -e /var/www/webroot/${i} ] || echo '{}' > /var/www/webroot/${i};
done

if [ -f /var/www/webroot/.vapenv ]; then
    source /var/www/webroot/.vapenv;
    bash /var/www/webroot/vap.sh configure --project-domain=${OS_PROJECT_DOMAIN_NAME} --user-domain=${OS_USER_DOMAIN_NAME} --project=${OS_PROJECT_NAME} --username=${OS_USERNAME} --password=${OS_PASSWORD} --url=${OS_AUTH_URL} --vap-stack-name=${VAP_STACK_NAME} --format=json; 
else
    true
fi
