# Automated PaaS Installer on Virtuozzo Infrastructure/Cloud

This project helps you create PaaS (Virtuozzo Application Management) on top of the [Virtuozzo Infrastructure](https://www.virtuozzo.com/infrastructure/) or [Virtuozzo Cloud](https://www.virtuozzo.com/cloud/) cluster.

- **[Prerequisites](#installation-prerequisites)** – ensure that you meet all the installation requirements
- **[Prepare Infrastructure](#infrastructure-configuration)** – configure your Virtuozzo Infrastructure/Cloud cluster via UI or CLI
- **[PaaS Web Installer](#paas-web-installer)** – run the automatic PaaS installer
- **[Remove Virtuozzo Application Management Stack](#remove-virtuozzo-application-management-stack)** – delete unnecessary Virtuozzo Application Management stacks

> **Note:** The automated installer in this repository covers basic installation steps and is intended for PoC and demo deployments only. For production deployments with full capabilities (including monitoring, platform patcher installation, backup configuration, etc.), please contact the Virtuozzo team.


## Installation Prerequisites

Before starting the installation, make the following preparations:

1\. Get **Virtuozzo Infrastructure/Cloud cluster** account and obtain a **Virtuozzo Application Management license** ([send a request](https://forms.office.com/e/4F667yc4j3)).

2\. Upload the latest **Virtuozzo Application Management qcow2 template** to your cluster via admin UI or CLI. We recommend the latter option as it is faster:

- Login to your physical Virtuozzo Infrastructure cluster primary node via SSH.
- Download the latest *Virtuozzo Application Management qcow2* template from the [repository](https://vap-images.virtuozzo.dev/vap-images/latest/). For example, with the following command:
```
wget https://vap-images.virtuozzo.dev/vap-images/latest/vap-8-14-3.qcow2
```
- Create an image:
```
vinfra service compute image create vap-8-14-3 --disk-format qcow2 --container-format bare --file vap-8-14-3.qcow2 --public --wait
```

3\. Check [PaaS requirements](https://www.virtuozzo.com/application-management-admin-docs/hardware-requirements-local-storage/) and, if needed, [create flavors](https://docs.virtuozzo.com/virtuozzo_infrastructure_7_2_admins_guide/#creating-and-deleting-flavors.html) with sufficient resources in your Virtuozzo Infrastructure cluster.

4\. Ensure the cluster has a **publicly accessible** physical network:

- 1 IP for each VM
- 2 IPs for resolvers
- additional IP range if you want to use public IP for user environments

5\. Open the following ports on the Virtuozzo Infrastructure node before installing the "Virtuozzo Application Management installer" container: *5000, 8004, 8774, 8776, 9292, and 9696*.

> **Tip:** You can close access to these ports after successful installation.


## Infrastructure Configuration

We've prepared **GUI** and **CLI** installation scenarios for automatic Virtuozzo Infrastructure cluster configuration. The GUI flow just provides the visual interface to help perform installation and configuration without manual commands. Otherwise, both flows are similar and utilize the same set of the commands. Deployment does not require in-depth knowledge of the Virtuozzo Application Management or [Virtuozzo Infrastructure Openstack](https://github.com/virtuozzo/vhideploy).

> In some complex custom cases, you may prefer to use the OpenStack Heat template for Virtuozzo Application Management installation. Check the detailed [Virtuozzo Application Management Cluster Deployment with OpenStack Heat](https://github.com/virtuozzo/vap-installer-on-vhi/tree/8.14-3/installer) guide.

### GUI Installation

1\. Log in or register at any [Virtuozzo Application Management](https://www.virtuozzo.com/paas-partners/). Click the **Import** button at the top of the dashboard.

![Virtuozzo Application Management import](images/01-vap-import.png)

2\. Paste the following link in the opened window:

```
https://github.com/virtuozzo/vap-installer-on-vhi/blob/master/manifest.yml
```

![import Virtuozzo Application Management installer](images/02-import-vap-installer.png)

Click **Import** to proceed.

3\. Provide any preferred *Environment* domain and *Display Name*.

![Virtuozzo Application Management installer installation](images/03-vap-installer-installation.png)

Click **Install** and wait a few minutes for the platform to automatically create an environment to set up your Virtuozzo Infrastructure/Cloud infrastructure.

4\. Once installed, hover over the Python application server and click **Add-Ons**. Within the corresponding panel, you can see the *Virtuozzo Application Management Installer Add-On* that will perform all the needed actions.

![configure Virtuozzo Application Management installer add-on](images/04-configure-vap-installer-addon.png)

5\. Before proceeding, you need to **Configure** the add-on:

- ***Project Domain Name*** – name of the Virtuozzo Infrastructure project domain where all the VMs for the new PaaS will be created
- ***User Domain Name*** – name of the Virtuozzo Infrastructure user domain where all the VMs for the new PaaS will be created
- ***Project Name*** – name of the Virtuozzo Infrastructure project where all the VMs for the new PaaS will be created
- ***Username*** – Virtuozzo Infrastructure account user to create VMs
- ***Password*** – Virtuozzo Infrastructure account password to create VMs
- ***URL*** – Virtuozzo Infrastructure cluster API endpoint
- ***Virtuozzo Application Management Project Domain*** – name for your Virtuozzo Application Management project domain
- ***New SSH Key***
  - *enable* (recommended) - to automatically generate SSH key pair (public key will be uploaded to Virtuozzo Infrastructure cluster and private stored within the environment) for accessing your VMs
  - *disable* – to manually manage SSH keys for your VMs
- ***New SSH Key Name*** – name for the automatically generated public key uploaded to Virtuozzo Infrastructure cluster (only if **New SSH Key** is enabled)

![configure Virtuozzo Infrastructure cluster](images/05-configure-vhi-cluster.png)

Click **Configure** to confirm.

6\. Next, click the **New Virtuozzo Application Management** button within the add-on and provide the following data:

- ***SSH Key Name*** – public SSH key from the Virtuozzo Infrastructure cluster (automatically preselected if a new one was generated in the previous step)
- ***Installation Type*** – four installation types (*PoC*, *Sandbox*, *Production*, *High Performance Production*) are available
- ***RAM&CPU Infra*** – VM flavor for the *Infra* host
- ***RAM&CPU User*** – VM flavor for the *User* host

> **Note:** Ensure that selected flavors meet the requirements shown within the corresponding hints (automatically adjusted based on the preselected installation type).
>
> ![Virtuozzo Application Management requirements](images/06-vap-requirements.png)

- ***Virtuozzo Application Management Project Name*** – name of the required Virtuozzo Application Management project (same as specified in the previous step by default)
- ***Infra Storage, GB*** – storage volume size for the '**/**' and '**/vz**' partitions and for **swap** on Infra nodes
- ***User Storage, GB*** - storage volume size for the '**/**' and '**/vz**' partitions and for **swap** on User node(s)
- ***User Node Count*** – number of User hosts to be created within the platform
- ***Virtuozzo Infrastructure Public Subnet*** – cluster's public subnet to attach created instances
- ***Virtuozzo Application Management Image Name*** – a *qcow2* image with the PaaS version
- ***Install Virtuozzo Cloud Management*** – toggle to enable installation of Virtuozzo Cloud Management components (default: disabled)

![new Virtuozzo Application Management stack](images/07-new-vap-stack.png)

> **Note:** If you get an error, ensure the add-on is configured correctly (see the previous step).

7\. Click **New Virtuozzo Application Management** and confirm the creation via popup. You'll see a notification with a link to the PaaS installer (also stored in the ***/var/log/installer.log*** file) in several minutes.

![Virtuozzo Application Management installer link](images/08-vap-installer-link.png)

Follow the URL to access the PaaS web installer.

### CLI Installation

The CLI version of the guide may be needed in some specific cases. For example, if the public access for the API endpoint of the cluster is not configured. In such a case the commands can be executed manually from the Virtuozzo Infrastructure cluster controller node.

> **Note:** The ***openstackclient*** and ***heatclient*** software modules are required to work with the installer. Both should be pre-installed on Virtuozzo Infrastructure cluster. Otherwise, use the `pip install python-openstackclient` and `pip install python-heatclient` commands.

1\. Clone the installer repository from GitHub.

```
git clone https://github.com/virtuozzo/vap-installer-on-vhi
```

![git colone Virtuozzo Application Management installer repo](images/09-git-colone-vap-installer-repo.png)

2\. Go to the **~/vap-installer-on-vhi/installer/** directory. You can run the `vap.sh` script without any parameters to get the help message with information on the script usage and parameters.

```
cd vap-installer-on-vhi/installer/
bash vap.sh
```

![vap.sh help](images/10-vap-sh-help.png)

3\. Configure your stack by running the `vap.sh configure` command with the following parameters:

- ***project-domain*** – Virtuozzo Infrastructure cluster project domain name where all the VMs for the new PaaS will be created
- ***user-domain*** – Virtuozzo Infrastructure cluster user domain name where all the VMs for the new PaaS will be created
- ***project*** – Virtuozzo Infrastructure cluster project name where all the VMs for the new PaaS will be created
- ***username*** – Virtuozzo Infrastructure account user to create VMs
- ***password*** – Virtuozzo Infrastructure account password to create VMs
- ***url*** – Virtuozzo Infrastructure cluster API endpoint URL
- ***vap-stack-name*** - name for your Virtuozzo Application Management project domain
- ***new-ssh-key-name*** – name for the public SSH key; if specified, a new key pair will be automatically generated and public key uploaded to Virtuozzo Infrastructure cluster (optional)

```
bash vap.sh configure --project-domain={domain} --user-domain={domain} --project={project} --username={name} --password={password} --url={url} --vap-stack-name={stack} --new-ssh-key-name={SSH key name}
```

![vap.sh configure](images/11-vap-sh-configure.png)

4\. Create the required infrastructure with the `vap.sh create` command. Use the tables from the previous step response to choose the appropriate parameters (according to the [PaaS requirements](https://www.virtuozzo.com/application-management-admin-docs/hardware-requirements-local-storage/)):

- ***infra-flavor*** – infra node flavor (size)

> **For example:** Check the corresponding table from the previous step and select the **ID** of the appropriate flavor. Use the same approach for the *user-flavor*, *subnet*, and *image* parameters below.
>
> ![infra node flavor ID](images/11.1-infra-node-flavor-id.png)

- ***user-flavor*** – user node flavor (size)
- ***subnet*** – Virtuozzo Infrastructure cluster's public subnet
- ***image*** – an image with the PaaS version
- ***user-host-count*** – number of user hosts to create for the PaaS cluster
- ***infra-root-size*** – storage volume size (GB) for the '**/**' partition on Infra nodes
- ***infra-vz-size*** – storage volume size (GB) for the '**/vz**' partition on Infra nodes
- ***user-root-size*** – storage volume size (GB) for the '**/**' partition on User node(s)
- ***user-vz-size*** – storage volume size (GB) for the '**/vz**' partition on User node(s)
- ***infra-swap-size*** – Infra node swap size (GB)
- ***user-swap-size*** – User node swap size (GB)
- ***key-name*** - public SSH key from the Virtuozzo Infrastructure cluster
- ***install-cmp*** – enable Virtuozzo Cloud Management installation (true|false, default: false)

```
bash vap.sh create --infra-flavor={ID} --user-flavor={ID} --subnet={ID} --image={ID} --user-host-count={number} --infra-root-size={GB} --infra-vz-size={GB} --user-root-size={GB} --user-vz-size={GB} --infra-swap-size={GB} --user-swap-size={GB} --key-name={SSH key name} --install-cmp={true|false}
```

![vap.sh create](images/12-vap-sh-create.png)

5\. Once completed, you'll see a web installer link for your PaaS (also stored in the ***/var/log/installer.log*** file).

![Virtuozzo Application Management installer CLI link](images/13-vap-installer-cli-link.png)

Open the URL and complete the installation via web installer.


## PaaS Web Installer

Web installer for Virtuozzo Application Management automates all the operations required to get the PaaS. You just need to provide the following data before the start:

- ***System User Email*** – specify the email for the platform admin user
- ***License Key*** – provide a license key for the business edition of the PaaS (obtained from the Support Team via the [form](https://forms.office.com/e/4F667yc4j3))
- ***Platform Entry Point IP*** – automatically obtained from the previously provided data (not editable)
- ***Domain*** – specify the preferred domain name for the platform; use the **Custom Domain** toggle to:
  - *disabled* – provide a third-level domain name for the default DNS zone with an automatic delegation
  - *enabled* – specify your custom domain (requires [manual delegation](https://www.virtuozzo.com/application-management-admin-docs/dns-zones-delegation-requirements/) to the platform entry point IP, it will be verified before starting the installation)
- ***Install Monitoring*** – enable if you want to configure default integration with the Prometheus monitoring system (disable to configure monitoring manually)

![Virtuozzo Application Management web installer](images/14-vap-web-installer.png)

Click **Install** to start the installation. Be patient, as the process can take up to 10-20 minutes, depending on your hardware.

![web installer progress](images/15-web-installer-progress.png)

Once ready, you'll see the admin user credentials and links to the **Ops** (admin panel) and **Dev** (user dashboard) panels.

![Virtuozzo Application Management installation success](images/16-vap-installation-success.png)

That's all! The platform is ready for [post-installation configurations](https://www.virtuozzo.com/application-management-admin-docs/onboarding-guide/).


## Remove Virtuozzo Application Management Stack

If you decide to remove your Virtuozzo Application Management project from the Virtuozzo Infrastructure cluster, you can use the [OpenStack CLI](https://docs.virtuozzo.com/virtuozzo_infrastructure_7_2_admins_guide/#connecting-to-openstack-command-line-interface.html) functionality.

1\. Create or edit the OpenStack source file based on the provided example:

- **OS_PROJECT_DOMAIN_NAME** - the name of the domain to deploy the stack
- **OS_USER_DOMAIN_NAME** - the name of the user domain
- **OS_PROJECT_NAME** - the name of the project to deploy the stack
- **OS_USERNAME** - user name
- **OS_PASSWORD** - user password
- **OS_AUTH_URL** - the URL of the OpenStack endpoint, it must be published and available

```
vim project.sh
```

![project configs](images/17-project-configs.png)

2\. Load the source file:

```
source project.sh
```

![source project configs](images/18-source-project-configs.png)

3\. Get the stack list:

```
openstack stack list
```

![list stacks](images/19-list-stacks.png)

4\. Remove the required stack:

```
openstack stack delete {name}
```

![delete stack](images/20-delete-stack.png)
