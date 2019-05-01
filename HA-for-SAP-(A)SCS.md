# Azure Virtual Machines high availability for SAP NetWeaver on Linux using SIOS Protection Suite

 This article describes how to deploy the virtual machines, configure the virtual machines, install the cluster framework, and install a highly available SAP NetWeaver 7.50 system, using SIOS Protection Suite. In the example configurations, installation commands etc., the ASCS instance is number 00, the ERS instance number 10, the Primary Application instance (PAS)  and the Application instance (AAS) is 00. SAP System ID S4D is used.

 This article explains how to achieve high availability for SAP NetWeaver application with SIOS Protection Suite for RHEL & SLES. The database layer is covered in detail in this [article](HA-for-SAP-HANA-DB.md).

 Read the following SAP Notes and papers first

 SAP Note [1662610](https://launchpad.support.sap.com/#/notes/1662610) Support details for SIOS Protection Suite for Linux

 SAP Note [1928533](https://launchpad.support.sap.com/#/notes/1928533), which has:

- List of Azure VM sizes that are supported for the deployment of SAP software
- Important capacity information for Azure VM sizes
- Supported SAP software, and operating system (OS) and database combinations
- Required SAP kernel version for Windows and Linux on Microsoft Azure

 SAP Note [2015553](https://launchpad.support.sap.com/#/notes/2015553) lists prerequisites for SAP-supported SAP software deployments in Azure.

 SAP Note [2002167](https://launchpad.support.sap.com/#/notes/2002167) has recommended OS settings for Red Hat Enterprise Linux

 SAP Note [1984787](https://launchpad.support.sap.com/#/notes/1984787) has general information about SUSE Linux Enterprise Server 12.

 SAP Note [2178632](https://launchpad.support.sap.com/#/notes/2178632) has detailed information about all monitoring metrics reported for SAP in Azure.

 SAP Note [2191498](https://launchpad.support.sap.com/#/notes/2191498) has the required SAP Host Agent version for Linux in Azure.

 SAP Note [2243692](https://launchpad.support.sap.com/#/notes/2243692) has information about SAP licensing on Linux in Azure.

 SAP Note [1999351](https://launchpad.support.sap.com/#/notes/1999351) has additional troubleshooting information for the Azure Enhanced Monitoring Extension for SAP.

 SAP Community WIKI has all required SAP Notes for Linux.

 Azure Virtual Machines planning and implementation for SAP on Linux

 Azure Virtual Machines deployment for SAP on Linux

 Azure Virtual Machines DBMS deployment for SAP on Linux

## 1. Overview

  High availability(HA) for SAP Netweaver central services requires shared storage. To achieve that on Linux virtual machine so far it was necessary to build separate highly available NFS cluster.

  Now it is possible to achieve SAP Netweaver HA by using storage replication using SIOS Datakeeper of SIOS Protection Suite. Using SIOS Datakeeper's Block level Replication   NetApp Files for the shared storage eliminates the need for additional NFS cluster. SIOS Protection Suite takes care of the SAP Netweaver central services(ASCS/SCS) failover.  

  ![ASCS](/99_images/Architecture_Diragram_ASCS.jpg)  

  ![HANA-DB](/99_images/ASCS1.png)  

  SAP NetWeaver ASCS, SAP NetWeaver SCS, SAP NetWeaver ERS, and the SAP HANA database use virtual hostname and virtual IP addresses. SIOS Enhanced IP GenApp is used to failover virtual IP address. Azure [Load balancer](https://docs.microsoft.com/en-us/azure/load-balancer/load-balancer-overview) can also be used.  

  The following list shows the configuration of the (A)SCS and ERS IP addresses & Virtual Hostnames configured in DNS.

   |Components     | hostname     | IP address |  VIP       |  VHOSTNAME |
   | --------------| -------------|------------| -----------|----------- |
   |SAP ASCS Pool  | azsuascs1    | 11.1.2.61  |  11.1.2.60 |  s4dascs   |
   |               | azsuascs2    | 11.1.2.62  |  11.1.2.70 |  s4ders    |  
   |SAP App Pool   | azsusap1     | 11.1.2.53  |            |            |
   |               | azsusap2     | 11.1.2.54  |            |            |
   |SIOS Witness   | azsusapwit1  | 11.1.2.65  |            |            |

## 2. Install SAP (A)SCS/ERS

 Use an terraform script from [github](https://github.com/BalaAnbalagan/SAP-on-Azure-using-Terraform) to deploy all required Azure resources, including the virtual machines, availability set etc., and in this example we are not using Load Balancer. You can also deploy the resources manually.

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

 Azure IP GenApp run the following Azure CLI command to Switch the Secondary IP from one node to the other in a cluster.

 ```bash
 az network nic ip-config create --resource-group SIOS-SUSE --nic-name NIC_APP-azsuascs1 --private-ip-address 11.1.2.60 --name S4DASCS
 ```

## [4. Install SIOS Protection Suite & Recovery Kits](Install-SPS-Components.md)

## 5. Configure A(SCS) cluster

### [1. Create Communication Path between Cluster Nodes and Witness](Create-Comm-path-SCS.md)

### [2. Create SIOS Enhanced Azure IP Gen App Resource](Create-Azure-IP-GenApp.md)

### [3. Create IP Resource](Create-IP-Resource-scs.md)

### [4. Create Dependency between IP Resource & Azure IP Gen App](Create-dep-ip-az-ascs.md)

## 6. [A] Install SAP NetWeaver ASCS

 Install SAP NetWeaver ASCS as root on the first node using a virtual hostname that maps to the IP resouce created in privious step i.e.,  s4dascs, 11.1.2.60  

 You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst. You can use parameter SAPINST_USE_HOSTNAME to install SAP, using virtual hostname.

 ```bash
 sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin SAPINST_USE_HOSTNAME=S4DASCS
 ```

## 7. [A] Install SAP NetWeaver ERS

 Install SAP NetWeaver ERS as root on the second node using a virtual hostname that maps to the IP address of the load balancer frontend configuration for the ERS, for example  s4ders, 11.1.2.70 and the instance number is 10.

 You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst. You can use parameter SAPINST_USE_HOSTNAME to install SAP, using  virtual hostname.

 ```bash
 sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin SAPINST_USE_HOSTNAME=S4DERS
 ```

## [8. Create Data Replication Resource for (A)SCS Mount Point](create-data-rep-ascs00.md)


## 9. Install database Instance

  In this example, SAP NetWeaver is installed on SAP HANA. You can use every supported database for this installation. For more information on how to install SAP HANA in Azure, see High availability of SAP HANA on Azure VMs on Red Hat Enterprise Linux. For a list of supported databases, see SAP Note 1928533.

  Run the SAP database instance installation

  Install the SAP NetWeaver database instance as root using a virtual hostname that maps to the IP address of the floating hostname of the database for example s4ddb and 11.1.2.50.

  You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst.

  ```bash
  sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin
  ```

## 10. SAP NetWeaver application server installation

  Follow these steps to install an SAP application server.

  Prepare application server.

  Follow the steps in the chapter SAP NetWeaver application server preparation above to prepare the application server.

  Install SAP NetWeaver application server.

  Install a primary or additional SAP NetWeaver applications server.

  You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst.

  ```bash
  sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin
  ```

## 11. Update SAP HANA secure store

  Update the SAP HANA secure store to point to the virtual name of the SAP HANA System Replication setup.

  Run the following command to list the entries as \<sid>adm

  ```bash
  hdbuserstore List
  ```

  This should list all entries and should look similar to

  ```console
  DATA FILE : /home/s4dadm/.hdb/azsusap1/SSFS\_HDB.DAT
  KEY FILE : /home/s4dadm/.hdb/azsusap1/SSFS\_HDB.KEY
  KEY DEFAULT
  ENV : s4ddb.provingground.net:30013
  USER: S4HABAP
  DATABASE: S4D
  ```
