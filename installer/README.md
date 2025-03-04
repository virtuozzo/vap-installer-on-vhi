# VAP Cluster Deployment with OpenStack Heat

This repository contains Heat templates for deploying a VAP (Virtuozzo Application Platform) cluster on OpenStack.

Read [Installation Prerequisites](https://github.com/virtuozzo/vap-installer-on-vhi/tree/master?tab=readme-ov-file#installation-prerequisites) before deploying.

## Openstack Heat Prerequisites

### 1. Heat Client Installation

Install the OpenStack CLI and Heat client:
```bash
pip install python-openstackclient python-heatclient
```

### 2. Project Configuration

Create a `project.sh` file with your OpenStack credentials and source it before running the deployment:

```bash
#!/bin/bash
export OS_PROJECT_DOMAIN_NAME=<domain_for_your_project>
export OS_USER_DOMAIN_NAME=<domain_for_your_user>
export OS_PROJECT_NAME=<your_target_project>
export OS_USERNAME="user@virtuozzo.com"
export OS_PASSWORD="Password"
export OS_AUTH_URL=https://<domain_name_or_ip>:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_AUTH_TYPE=password
export OS_INSECURE=true
export NOVACLIENT_INSECURE=true
export NEUTRONCLIENT_INSECURE=true
export CINDERCLIENT_INSECURE=true
export OS_PLACEMENT_API_VERSION=1.22
```

Source the file:
```bash
source project.sh
```

Check the project configuration (no errors should be reported):
```bash
openstack stack list
```

## Template Parameters

### VAP.yaml Parameters

#### Required Parameters:
- `infra_flavor`: Flavor name for infrastructure nodes. 
- `user_flavor`: Flavor name for user nodes
- `public_subnet`: Public subnet name or ID
- `key_name`: SSH key name for VM access

#### Optional Parameters:
- `user_hosts_count`: Number of user nodes (default: 3, range: 0-100)
- `image`: Base image name (default: vap-8-12-1)
- `public_network`: Public network name (default: public)
- `proxy`: HTTP/HTTPS proxy URL
- `nameserver`: Custom DNS server IP

#### Storage Parameters:
- `storage_policy_root`: Storage policy for root volumes (default: default)
- `storage_policy_infra_vz`: Storage policy for infra /vz volumes (default: default)
- `storage_policy_user_vz`: Storage policy for user /vz volumes (default: default)
- `storage_policy_vap_platform_data`: Storage policy for platform data (default: default)

#### Volume Sizes:
- `infra_root_volume_size`: Root volume size for infra nodes (100-2000 GB)
- `user_root_volume_size`: Root volume size for user nodes (100-2000 GB)
- `infra_vz_volume_size`: /vz volume size for infra nodes (100-5000 GB)
- `user_vz_volume_size`: /vz volume size for user nodes (100-10000 GB)
- `vap_platform_data_volume_size`: Volume size for uploader and docker cache (100-2500 GB)
- `infra_swap_volume_size`: Swap size for infra nodes (1-32 GB)
- `user_swap_volume_size`: Swap size for user nodes (1-32 GB)

## Deployment Examples

### Basic Deployment

```bash
openstack stack create -t VAP.yaml -e params.yaml my-vap-cluster
```

Example `params.yaml`:
```yaml
parameters:
  infra_flavor: "m1.xlarge"
  user_flavor: "m1.large"
  public_subnet: "public-subnet-1"
  user_hosts_count: 4
  key_name: "my-ssh-key"
```

### Basic Deployment with command line parameters:

```bash
openstack stack create -t VAP.yaml \
    --parameter infra_flavor=m1.xlarge \
    --parameter user_flavor=m1.large \
    --parameter public_subnet=public-subnet-1 \
    --parameter user_hosts_count=4 \
    --parameter key_name=my-ssh-key \
my-vap-cluster
```

### Advanced Deployment with Custom Storage

```bash
openstack stack create -t VAP.yaml -e advanced-params.yaml my-vap-cluster
```

Example `advanced-params.yaml`:
```yaml
parameters:
  infra_flavor: "m1.xlarge"
  user_flavor: "m1.large"
  public_subnet: "public-subnet-1"
  user_hosts_count: 10
  key_name: "my-ssh-key"
  storage_policy_root: "ssd-tier"
  storage_policy_infra_vz: "high-iops"
  storage_policy_user_vz: "standard"
  infra_root_volume_size: 200
  user_root_volume_size: 150
  infra_vz_volume_size: 1000
  user_vz_volume_size: 500
  proxy: "http://proxy.example.com:3128"
  nameserver: "172.16.1.1"
```
### Advanced Deployment with command line parameters:

```bash
openstack stack create -t VAP.yaml \
    --parameter infra_flavor=m1.xlarge \
    --parameter user_flavor=m1.large \
    --parameter public_subnet=public-subnet-1 \
    --parameter user_hosts_count=4 \
    --parameter key_name=my-ssh-key \
    --parameter storage_policy_root=ssd-tier \
    --parameter storage_policy_infra_vz=high-iops \
    --parameter storage_policy_user_vz=standard \
    --parameter infra_root_volume_size=200 \
    --parameter user_root_volume_size=150 \
    --parameter infra_vz_volume_size=1000 \
    --parameter user_vz_volume_size=500 \
    --parameter proxy=http://proxy.example.com:3128 \
    --parameter nameserver=172.16.1.1 \
my-vap-cluster
```

## Monitoring Deployment

Check the stack status:
```bash
openstack stack list
openstack stack show my-vap-cluster
```

View stack events:
```bash
openstack stack event list my-vap-cluster
```

## Next Steps

Show variables:
```bash
openstack stack output show my-vap-cluster
```
Example of output:
```
+-------------------+--------------------------------------------------------------------+
| Field             | Value                                                              |
+-------------------+--------------------------------------------------------------------+
| public_ip_infra1  | {                                                                  |
|                   |   "output_key": "public_ip_infra1",                                |
|                   |   "description": "public IP address of the infra node",            |
|                   |   "output_value": "172.16.1.100"                                   |
|                   | }                                                                  |
| webinstaller_link | {                                                                  |
|                   |   "output_key": "webinstaller_link",                               |
|                   |   "description": "installer webserver password",                   |
|                   |   "output_value": "https://user:password@172.16.1.100:8081"        |
|                   | }                                                                  |
+-------------------+--------------------------------------------------------------------+

```

Use "webinstaller_link" to access the installer and [continue the installation](https://github.com/virtuozzo/vap-installer-on-vhi/tree/master?tab=readme-ov-file#paas-web-installer).


## Cleanup

To delete the stack and all associated resources:
```bash
openstack stack delete my-vap-cluster
```
