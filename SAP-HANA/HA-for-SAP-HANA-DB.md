# High availability of SAP HANA on Azure VMs on Server using SIOS Protection Suite

On Azure virtual machines (VMs), HANA System Replication is the only supported high availability solution. SAP HANA Replication consists of one primary node and at least one secondary node. Changes to the data on the primary node are replicated to the secondary node synchronously or asynchronously.

This article describes how to deploy and configure the virtual machines, install the cluster framework, and install and configure SAP HANA System Replication. In the example configurations, installation commands, instance number 00, and HANA System ID S4D are used.

Read the following SAP Notes and papers first:
SAP Note [1662610](https://launchpad.support.sap.com/#/notes/1662610) Support details for SIOS Protection Suite for Linux

SAP Note [1928533](https://launchpad.support.sap.com/#/notes/1928533), which has:

- The list of Azure VM sizes that are supported for the deployment of SAP software.
- Important capacity information for Azure VM sizes.
- The supported SAP software, and operating system (OS) and database combinations.
- The required SAP kernel version for Windows and Linux on Microsoft Azure.

SAP Note [2015553](https://launchpad.support.sap.com/#/notes/2015553) lists the prerequisites for SAP-supported SAP software deployments in Azure.

SAP Note [2205917](https://launchpad.support.sap.com/#/notes/2205917) has recommended OS settings for SUSE Linux Enterprise Server for SAP Applications.

SAP Note [2009879](https://launchpad.support.sap.com/#/notes/2009879) has SAP HANA Guidelines for Red Hat Enterprise Linux

SAP Note [1944799](https://launchpad.support.sap.com/#/notes/1944799) has SAP HANA Guidelines for SUSE Linux Enterprise Server for SAP Applications.

SAP Note [2178632](https://launchpad.support.sap.com/#/notes/2178632) has detailed information about all of the monitoring metrics that are reported for SAP in Azure.

SAP Note [2191498](https://launchpad.support.sap.com/#/notes/2191498) has the required SAP Host Agent version for Linux in Azure.

SAP Note [2243692](https://launchpad.support.sap.com/#/notes/2243692) has information about SAP licensing on Linux in Azure.

SAP Note [1984787](https://launchpad.support.sap.com/#/notes/1984787) has general information about SUSE Linux Enterprise Server 12.

SAP Note [1999351](https://launchpad.support.sap.com/#/notes/1999351) has additional troubleshooting information for the Azure Enhanced Monitoring Extension for SAP.

SAP Note [401162](https://launchpad.support.sap.com/#/notes/401162) has information on how to avoid "address already in use" when setting up HANA System Replication.

[SAP Community WIKI](https://wiki.scn.sap.com/wiki/display/HOME/SAPonLinuxNotes) has all of the required SAP Notes for Linux.

[SAP HANA Certified IaaS Platforms](https://www.sap.com/dmc/exp/2014-09-02-hana-hardware/enEN/iaas.html#categories=Microsoft%20Azure)

[Azure Virtual Machines planning and implementation for SAP on Linux guide](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/planning-guide).

[Azure Virtual Machines deployment for SAP on Linux](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/deployment-guide) (this article).

[Azure Virtual Machines DBMS deployment for SAP on Linux guide](https://docs.microsoft.com/en-us/azure/virtual-machines/workloads/sap/dbms-guide).

[SUSE Linux Enterprise Server for SAP Applications 12 SP3 best practices guides](https://www.suse.com/documentation/sles-for-sap-12/)

- Setting up an SAP HANA SR Performance Optimized Infrastructure (SLES for SAP Applications 12 SP1). The guide contains all of the required information to set up SAP HANA System Replication for on-premises development. Use this guide as a baseline.
- Setting up an SAP HANA SR Cost Optimized Infrastructure (SLES for SAP Applications 12 SP1)

## 1. Overview

To achieve high availability, SAP HANA is installed on two virtual machines. The data is replicated by using HANA System Replication.

![ASCS](/99_images/Architecture_Diragram_ASCS.png)  

![HANA-DB](/SAP-HANA//Images/SIOS-HANA-Cluster.png)

The following list shows the configuration of the (A)SCS and ERS IP addresses & Virtual Hostnames configured in DNS.

  |Components     | hostname     | IP address |  VIP       |  VHOSTNAME |
  | --------------| -------------|------------| -----------|----------- |
  |SAP DB Pool    | azsuhana1    | 11.1.2.51  |  11.1.2.50 |  s4ddb     |
  |               | azsuhana2    | 11.1.2.52  |            |            |
  |SIOS Witness   | azsusapwit2  | 11.1.2.66  |            |            |

## 2. Provission SAP HANA and Witness Infrastructure

Use an terraform script from [Proving Ground Infrastructure Provisioning Git](https://github.com/BalaAnbalagan/SAP-on-Azure-Proving-Ground) to deploy all required Azure resources, including the virtual machines, availability set etc., and in this example we are not using Load Balancer. You can also deploy the resources manually.

Please follow the respective document in the Proving Ground Infrastructure Provisioning Git

## 3. Install Azure CLI  

 Install Azure CLI on the (A)SCS cluster nodes which is a pre-requisites for SIOS Enhanced Azure IP GenApp. Please refer the installation procedure respective to OS

- [RHEL](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-yum?view=azure-cli-latest)  
- [SLES](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-zypper?view=azure-cli-latest)  

 Please login to portal.azure.com from the server.

 ```bash
 az login --use-device-code
 ```

 ```console
 To sign in, use a web browser to open the page https://microsoft.com/devicelogin and enter the code B3D42JUFD to authenticate
 ```

## 4. Install SIOS Protection Suite & Recovery Kits

![ ](/99_images/SIOS-Components-Functions-2.png)

The following SIOS components installed in respective nodes.

LifeKeeper Core

- azsuhana1
- azsuhana2
- azsusapwit2

Witness/Quorum

- azsusapwit2

Note:- recommended to use 1 witness/cluster

SAP HANA 2.0 Application Reovery Kit & IP Recovery Kit

- azsuhana1
- azsuhana2

[Please follow the installation screenshots here](/SIOS/Install-SPS-Components.md)

## 5. Create Communication Path between Cluster Nodes and Witness

To create a communication path between a pair of servers, you must define the path individually on both servers. LifeKeeper allows you to create both TCP (TCP/IP) and TTY communication paths between a pair of servers. Only one TTY path can be created between a given pair. However, you can create multiple TCP communication paths between a pair of servers by specifying the local and remote addresses that are to be the end-points of the path. A priority value is used to tell LifeKeeper the order in which TCP paths to a given remote server should be used.

Please refer the screenshots on [how to create communication path](Create-Comm-path-HANA.md)

## 6. Create Floating IP for HANA cluster

In this section we will be using SIOS Enhanced Azure IP Generic Application which creates the secondary IP Configuration for the given NIC on the VM

 Azure IP GenApp run the following Azure CLI command to Switch the Secondary IP from one node to the other in a cluster.

 ```bash
 az network nic ip-config create --resource-group SIOS-SUSE --nic-name NIC_APP-azsuhana1 --private-ip-address 11.1.2.50 --name S4DDB
 ```

  Note:

- SIOS Enhanced IP GenApp adds 2 mins to the failover time

- It can be used in scenario's where ILB is not avialble

- While using Azure ILB, this step is not required

The SIOS IP Recovery Kit is used to failover the IP between the cluster nodes.

Please refer the following links to create the resources

- ### [1. Create SIOS Enhanced Azure IP Gen App Resource for HANA](Create-Azure-IP-GenApp-HANA.md)

- ### [2. Create IP Resource for HANA](Create-IP-Resource-HANA.md)

## 7. Install SAP HANA

The steps in this section use the following prefixes:

- [A] The step applies to all nodes.
- [1] The step applies to node 1 only.

### 1. [A] Run post-processing script ps-db.bash

### 2. [A] Run the hdblcm program from the HANA Installation Media. Enter the following values at the prompt

- Choose installation: Enter 1.
- Select additional components for installation: Enter 1.
- Enter Installation Path [/hana/shared]: Select Enter.
- Enter Local Host Name [..]: Select Enter.
- Do you want to add additional hosts to the system? (y/n) [n]: Select Enter.
- Enter SAP HANA System ID: Enter the SID of HANA, for example HN1.
- Enter Instance Number [00]: Enter the HANA Instance number. Enter 03 if you used the Azure template or followed the manual deployment section of this article.
- Select Database Mode / Enter Index [1]: Select Enter.
- Select System Usage / Enter Index [4]: Select the system usage value.
- Enter Location of Data Volumes [/hana/data/S4D]: Select Enter.
- Enter Location of Log Volumes [/hana/log/S4D]: Select Enter.
- Restrict maximum memory allocation? [n]: Select Enter.
- Enter Certificate Host Name For Host '...' [...]: Select Enter.
- Enter SAP Host Agent User (sapadm) Password: Enter the host agent user password.
- Confirm SAP Host Agent User (sapadm) Password: Enter the host agent user password again to confirm.
- Enter System Administrator (hdbadm) Password: Enter the system administrator password.
- Confirm System Administrator (hdbadm) Password: Enter the system administrator password again to confirm.
- Enter System Administrator Home Directory [/usr/sap/S4D/home]: Select Enter.
- Enter System Administrator Login Shell [/bin/sh]: Select Enter.
- Enter System Administrator User ID [1001]: Select Enter.
- Enter ID of User Group (sapsys) [79]: Select Enter.
- Enter Database User (SYSTEM) Password: Enter the database user password.
- Confirm Database User (SYSTEM) Password: Enter the database user password again to confirm.
- Restart system after machine reboot? [n]: Select Enter.
- Do you want to continue? (y/n): Validate the summary. Enter y to continue.

### 3. [A] Upgrade the SAP Host Agent

Download the latest SAP Host Agent archive from the SAP Software Center and run the following command to upgrade the agent. Replace the path to the archive to point to the file that you downloaded:

```code
sudo /usr/sap/hostctrl/exe/saphostexec -upgrade -archive <path to SAP Host Agent SAR>
```

## 8. Configure SAP HANA 2.0 System Replication

- [A] \: The step applies to all nodes.
- [1] \: The step applies to node 1 only.

### 1. [1] Configure System Replication on the first node

Back up the databases as \<hanasid>adm:

```code
hdbsql -d SYSTEMDB -u SYSTEM -p "passwd" -i 00 "BACKUP DATA USING FILE ('initialbackupSYS')"
hdbsql -d S4D -u SYSTEM -p "passwd" -i 00 "BACKUP DATA USING FILE ('initialbackupS4D')"
```

Copy the system PKI files to the secondary site:

```code
scp /usr/sap/S4D/SYS/global/security/rsecssfs/data/SSFS_S4D.DAT   azsuhana2:/usr/sap/S4D/SYS/global/security/rsecssfs/data/
scp /usr/sap/S4D/SYS/global/security/rsecssfs/key/SSFS_S4D.KEY  azsuhana2:/usr/sap/S4D/SYS/global/security/rsecssfs/key/
```

Create the primary site:

```code
hdbnsutil -sr_enable --name=left
```

![Primary HANA System Replication Enabled](/99_images/image025.png)*Primary HANA System Replication Enabled*

### 2. [2] Configure System Replication on the second node

Register the second node to start the system replication. Run the following command as \<hanasid>adm :

```code
sapcontrol -nr 00 -function StopWait 600 10
hdbnsutil -sr_register --remoteName=left --remoteHost=azsuhana1 --remoteInstance=00 --replicationMode=syncmem --operationMode=logreplay --name=right
```

HSR status from Primary node

![HSR status from Primary node](/99_images/image030.png)

HSR status from a secondary node

![HSR status from secondary node](/99_images/image031.png)

Secondary System Starts after initial Sync

![Secondary System Starts after initial Sync](/99_images/image028.png)

Replication Status in HANA Studio

![Replication Status in HANA Studio](/99_images/image029.png)

## 9. Create SAP HANA Resource

Please refer the screenshots on [How to create HANA resource](Create-sap-hana.md)

Please refer the screenshot on [How to create dependency between HANA & VIP resource](Create-dep-hana-vip.md)

## 10. Failover Testing

Please refere the screensots on [Failover Testing](SIOS-HANA-Failover-Testing.md)
