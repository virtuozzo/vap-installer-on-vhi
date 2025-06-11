# VAP Cluster Deployment with OpenStack Heat

Heat is the orchestration service in OpenStack, which allows users to create and manage cloud resources using templates. This repository contains Heat templates for the automated deployment of a VAP (Virtuozzo Application Platform) cluster.

> Read [Installation Prerequisites](https://github.com/virtuozzo/vap-installer-on-vhi/tree/master?tab=readme-ov-file#installation-prerequisites) before deploying.


## Deployment Prerequisites

1\. The ***openstackclient*** and ***heatclient*** software modules are required and should be pre-installed to work with the Heat templates.

If you haven't before, install the OpenStack CLI and Heat client:

```bash
pip install python-openstackclient python-heatclient
```

2\. Create the `project.sh` OpenStack source file with VAP project configurations. Use the following example as a template:

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

3\. Source the project file and verify configuration (no errors should be reported) before running the deployment:

```bash
source project.sh
openstack stack list
```


## Template Parameters

The `VAP.yaml` OpenStack Heat template is used to deploy a VAP cluster. It uses a set of parameters that should be provided during the deployment:

- **Required Parameters**
  - `infra_flavor`: Flavor name for infrastructure nodes
  - `user_flavor`: Flavor name for user nodes
  - `public_subnet`: Public subnet name or ID
  - `key_name`: SSH key name for VM access
- **Optional Parameters**
  - `user_hosts_count`: Number of user nodes (default: 3; range: 0-100)
  - `image`: Base image name (default: vap-8-13-1)
  - `public_network`: Public network name (default: public)
  - `proxy`: HTTP/HTTPS proxy URL
  - `nameserver`: Custom DNS server IP
- **Storage Parameters**
  - `storage_policy_root`: Storage policy for root volumes (default: default)
  - `storage_policy_infra_vz`: Storage policy for infra /vz volumes (default: default)
  - `storage_policy_user_vz`: Storage policy for user /vz volumes (default: default)
  - `storage_policy_vap_platform_data`: Storage policy for platform data (default: default)
- **Volume Size Parameters**
  - `infra_root_volume_size`: Root volume size for infra nodes (100-2000 GB)
  - `user_root_volume_size`: Root volume size for user nodes (100-2000 GB)
  - `infra_vz_volume_size`: /vz volume size for infra nodes (100-5000 GB)
  - `user_vz_volume_size`: /vz volume size for user nodes (100-10000 GB)
  - `vap_platform_data_volume_size`: Volume size for uploader and docker cache (100-2500 GB)
  - `infra_swap_volume_size`: Swap size for infra nodes (1-32 GB)
  - `user_swap_volume_size`: Swap size for user nodes (1-32 GB)

These parameters can be specified in a separate file (e.g., `params.yaml`) or passed as command line arguments.


## Deployment Examples

For basic deployment, only the required parameters are needed. For example, to deploy a VAP cluster with 4 user nodes:

```bash
openstack stack create -t VAP.yaml -e params.yaml my-vap-cluster
```

`params.yaml`:
```yaml
parameters:
  infra_flavor: "m1.xlarge"
  user_flavor: "m1.large"
  public_subnet: "public-subnet-1"
  user_hosts_count: 4
  key_name: "my-ssh-key"
```

> Alternatively, parameters can be specified directly in the command line:
> 
> ```bash
> openstack stack create -t VAP.yaml \
>     --parameter infra_flavor=m1.xlarge \
>     --parameter user_flavor=m1.large \
>     --parameter public_subnet=public-subnet-1 \
>     --parameter user_hosts_count=4 \
>     --parameter key_name=my-ssh-key \
> my-vap-cluster
> ```

For advanced deployment, additional parameters can be specified. For example, to customize the storage:

```bash
openstack stack create -t VAP.yaml -e advanced-params.yaml my-vap-cluster
```

`advanced-params.yaml`:
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

> Alternatively, parameters can be specified directly in the command line:
> 
> ```bash
> openstack stack create -t VAP.yaml \
>     --parameter infra_flavor=m1.xlarge \
>     --parameter user_flavor=m1.large \
>     --parameter public_subnet=public-subnet-1 \
>     --parameter user_hosts_count=4 \
>     --parameter key_name=my-ssh-key \
>     --parameter storage_policy_root=ssd-tier \
>     --parameter storage_policy_infra_vz=high-iops \
>     --parameter storage_policy_user_vz=standard \
>     --parameter infra_root_volume_size=200 \
>     --parameter user_root_volume_size=150 \
>     --parameter infra_vz_volume_size=1000 \
>     --parameter user_vz_volume_size=500 \
>     --parameter proxy=http://proxy.example.com:3128 \
>     --parameter nameserver=172.16.1.1 \
> my-vap-cluster
> ```


## Monitoring Deployment

You can monitor the deployment status by listing all stacks and view detailed information about the created stack:

```bash
openstack stack list
openstack stack show my-vap-cluster
```

For debugging, you can check the events list (actions and changes that have occurred during the lifecycle of the stack):

```bash
openstack stack event list my-vap-cluster
```

## Post-Deployment Actions

Once the deployment is complete, you can access the webinstaller to continue the installation. Use the following command to show stack variables and get the installer link:

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

Open "***webinstaller_link***" to [continue the installation](https://github.com/virtuozzo/vap-installer-on-vhi/tree/master?tab=readme-ov-file#paas-web-installer).


## Cleanup

To delete the stack and all associated resources, use the following command:

```bash
openstack stack delete my-vap-cluster
```
