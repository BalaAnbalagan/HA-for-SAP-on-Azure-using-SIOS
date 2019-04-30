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

## 4. Install SIOS Protection Suite

### 1. Preparing Installation Media

 download the following media from the FTP link sent by SIOS

- download the SIOS protection Suite's - sps.img
- download the HANA Application Recovery Kit based on your HANA version - HANA2-ARK.run
- download the Azure IP Recovery kit - SIOS_enhancedAzure_gen_app-02.02.00.tgz
- file name might be different based on the version

### 2. Mount the Installation Media

 ```bash
 mkdir -p /DVD
 mount /sapmedia/SIOS931/sps.img /DVD -t iso9660 -o loop
 mount: /dev/loop0 is write-protected, mounting read-only
 ```

### 3. Setup SIOS Protection Suite -- Witness Nodes

 ```bash
  cd /DVD
  ./setup
 ```

 Please proceed with the installation steps as shown below
 ![ ](/99_images/image008.png)
 ![ ](/99_images/image009.png)
 ![ ](/99_images/image010.png)
 Please repeat the steps on the second witness node too.

### 4. Setup SIOS Protection Suite - SAP Recovery Kit

 Install SAP Recovery kit in ASCS and HANA Nodes
 change directory to SIOS installation media which was mounted as /DVD

```bash
 cd /DVD
 ./setup
 ```

 ![Select install License Key](/99_images/image011.png)*Select install License Key*

 ![Enter the license path & click ok](/99_images/image012.png)*Enter the license path & click ok*

 ![Select Recovery kit Selection Menu](/99_images/image013.png)*Select Recovery kit Selection Menu*

 ![Select Application Suite](/99_images/image014.png)*Select Application Suite*

 ![Select Lifekeeper SAP Recovery kit](/99_images/image015.png)*Select Lifekeeper SAP Recovery kit*

 ![Select Lifekeeper Startup after install & Select Done](/99_images/image016.png)*Select Lifekeeper Startup after install & Select Done*

 ![Select Yes & Press Enter](/99_images/image017.png)*Select Yes & Press Enter*
  
 ![ ](/99_images/image018.png)*Installation completed*

 ![ ](/99_images/image019.png)*license check message*

 Please repeat the steps on all cluster Nodes

### 5. Create Communication Path between Cluster Nodes and Witness

Run LifeKeeper GUI

```bash
/opt/Lifekeeper/bin/lkGUIapp
```

![ ](/99_images/ASCS-communication-Path-1.png)

login using root

![ ](/99_images/ASCS-communication-Path-2.png)

![ ](/99_images/ASCS-communication-Path-3.png)

![ ](/99_images/ASCS-communication-Path-4.png)

![ ](/99_images/ASCS-communication-Path-5.png)

![ ](/99_images/ASCS-communication-Path-6.png)

![ ](/99_images/ASCS-communication-Path-7.png)

![ ](/99_images/ASCS-communication-Path-8.png)

![ ](/99_images/ASCS-communication-Path-9.png)

![ ](/99_images/ASCS-communication-Path-10.png)

![ ](/99_images/ASCS-communication-Path-11.png)

![ ](/99_images/ASCS-communication-Path-12.png)

![ ](/99_images/ASCS-communication-Path-13.png)

![ ](/99_images/ASCS-communication-Path-14.png)

![ ](/99_images/ASCS-communication-Path-15.png)

![ ](/99_images/ASCS-communication-Path-16.png)

![ ](/99_images/ASCS-communication-Path-17.png)

![ ](/99_images/ASCS-communication-Path-18.png)

![ ](/99_images/ASCS-communication-Path-19.png)

![ ](/99_images/ASCS-communication-Path-20.png)

![ ](/99_images/ASCS-communication-Path-21.png)

![ ](/99_images/ASCS-communication-Path-22.png)

![ ](/99_images/ASCS-communication-Path-23.png)

![ ](/99_images/ASCS-communication-Path-24.png)

![ ](/99_images/ASCS-communication-Path-25.png)

![ ](/99_images/ASCS-communication-Path.png)

### 6. Setup SIOS Enhanced Azure IP Gen Application

 You will receive the FTP link to download the tgz file.

- Use gunzip to unzip the tar file.
- Use command “tar -xvf” to untar the file
- Run the setup program
- NOTE: Make sure you put the files on a folder that is safe to execute. On some installations, programs need to be authorized to execute from certain folders. You can make sure  that the setup program has execute permission (chmod +x setup.)
- Repeat these steps on the other node.
- Note the folder where the files are stored (e.g. /root/folder

## 5. Configure A(SCS) cluster

### 1. Create floating IP for ASCS & ERS in SIOS Protection Suite

  ![Machine generated alternative text: Eile Edit Yiew Help ](/99_images/image074.png)

  Click + icon to create resource hierarchy

  ![Select Generic Application](/99_images/image075.png "Select Generic Application")

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image076.png "Select Intelligent, can be changed later")

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image077.png "Select the node 1")

  ![ ](/99_images/image078.png "provide the path where ip gen app is installed")

  ![ ](/99_images/image079.png "Will be picked the right file automatically")

  ![ ](/99_images/image080.png "Will be picked the right file automatically")

  ![ ](/99_images/image081.png "Will be picked the right file automatically")

  The application tag provided to be provided in the next screen is very important and the values are as follows

  1. Resource Group name in Azure

  2. The NIC name in Azure for the first node

  3. The IP address for the first node

  4. The NIC name in Azure for the second node

  5. The IP address for the second node

  6. The Virtual IP address to float between the 2 nodes.

  7. The adapter used, typically eth0.

  8. Name of the IP in Azure

  SIOS-SUSE NIC_APP-azsuascs1 11.1.2.61 NIC_APP-azsuers1 11.1.2.62 11.1.2.60 eth0 S4DASCS

  ![ ](/99_images/image082.png "Enter the Application Tag as above")
  
  ![ ](/99_images/image083.png "Select Yes")

  ![ ](/99_images/image084.png "Enter the Floating IP for SAP (A)SCS1")

  ![ ](/99_images/image085.png "Click Next")

  ![ ](/99_images/image086.png "Enter the Secondary (A)SCS hostname")

  ![ ](/99_images/image087.png "Select Intelligent & click next")

  ![ ](/99_images/image088.png "click next with priority as 1")

  ![ ](/99_images/image089.png "click next with priority as 10")

  ![ ](/99_images/image090.png "Click close")

  Don not extend the resource now, please Click close

  In Azure the ip will look as shown below

  ![ ](/99_images/image091.png "Secondary IP in portal.azure.com")

  In linux the secondary ip address will be added to the eth0 device

 ```bash
 ip add show
 ```

 ```console
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 inet 127.0.0.1/8 scope host lo
 valid_lft forever preferred_lft forever
 inet6 ::1/128 scope host
 valid_lft forever preferred_lft forever
 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
 link/ether 00:0d:3a:06:27:29 brd ff:ff:ff:ff:ff:ff
 inet 11.1.2.61/24 brd 11.1.2.255 scope global eth0
 valid_lft forever preferred_lft forever
 inet 11.1.2.60/24 scope global secondary eth0
 valid_lft forever preferred_lft forever
 inet6 fe80::20d:3aff:fe06:2729/64 scope link
 valid_lft forever preferred_lft forever
 ```

### 2. Create IP Resource Kit

 ![ ](/99_images/image092.png "select IP from the drill down menu and click next")

 ![ ](/99_images/image093.png "Select intelligent and click next")

 ![ ](/99_images/image094.png "Enter the floating ip for SAP (A)SCS ")

 ![ ](/99_images/image095.png "click next with promted netmask")

 ![ ](/99_images/image096.png "select the eth which needs to be protected and click next")

 ![ ](/99_images/image097.png "give a name for the resoure and click next")

 ![ ](/99_images/image098.png "click next")

 ![ ](/99_images/image099.png "Enter the secondary hostname and click next")

 ![ ](/99_images/image100.png "select intelligent and click next")

 ![ ](/99_images/image101.png "select priority 1 and click next")

 ![ ](/99_images/image102.png "select priority 10 and click next")

 ![ ](/99_images/image103.png "click next")

 Do not extend now, click close

 Create dependency

 Add ip-11.1.2.60 as dependency to vip-11.1.2.60

 ![ ](/99_images/image104.png "right click vip-11.1.2.60 and click create dependency")

 ![ ](/99_images/image105.png "select the ip-11.1.2.60 and click next")

 ![ ](/99_images/image106.png "click done")

### 3. [A] Install SAP NetWeaver ASCS

 Install SAP NetWeaver ASCS as root on the first node using a virtual hostname that maps to the IP resouce created in privious step i.e.,  s4dascs, 11.1.2.60  

 You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst. You can use parameter SAPINST_USE_HOSTNAME to install SAP, using virtual hostname.

 ```bash
 sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin SAPINST_USE_HOSTNAME=S4DASCS
 ```

### 4. [A] Install SAP NetWeaver ERS

 Install SAP NetWeaver ERS as root on the second node using a virtual hostname that maps to the IP address of the load balancer frontend configuration for the ERS, for example  s4ders, 11.1.2.70 and the instance number is 10.

 You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst. You can use parameter SAPINST_USE_HOSTNAME to install SAP, using  virtual hostname.

 ```bash
 sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin SAPINST_USE_HOSTNAME=S4DERS
 ```

### 5. Create Data Replication Resource for (A)SCS mount

   Click create resoure from the lkGUIapp

  ![ ](/99_images/image107.png "select Data Replication and click next")

  ![ ](/99_images/image108.png "select intelligent and click next")

  ![ ](/99_images/image109.png "select the primary node from which the (A)SCS mount to be replicated to secodary node")

  ![ ](/99_images/image110.png "select Replicate Existing Filesystem")

  ![ ](/99_images/image111.png "click continue")

  ![ ](/99_images/image112.png "select the existing mount point")

  ![ ](/99_images/image113.png "click next with replication resource tag")

  ![ ](/99_images/image114.png "click next for the filesystem resource tag")

  ![ ](/99_images/image115.png "select the bitmap file and click next")

  ![ ](/99_images/image116.png "select no for Asynchronous Replication")

  ![ ](/99_images/image117.png "click next")

  ![ ](/99_images/image118.png "select the secondary node and click next")

  ![ ](/99_images/image119.png "select intelligent and click next")

  ![ ](/99_images/image120.png "select priority 1 and click next")

  ![ ](/99_images/image121.png "select priority 10 and click next")

  ![ ](/99_images/image122.png "click next")

  Click close and do not click next to extent the resource to the target side yet.

### 6. Create SAP Resource SAP-S4D\_ASCS00

  Click create resource from lkGUIapp

  ![ ](/99_images/image123.png "select SAP")

  ![ ](/99_images/image124.png "select intelligent and click next")

  ![ ](/99_images/image125.png "select the primary node and click next")

  ![ ](/99_images/image126.png "select the SID and click next")

  ![ ](/99_images/image127.png "select the instance and click next")

  ![ ](/99_images/image128.png "select the ip-resoruce and click next")

  ![ ](/99_images/image129.png "provide a SAP resource tag and click next")

  ![ ](/99_images/image130.png "click next")

  ![ ](/99_images/image131.png "select the secondary node and click next")

  ![ ](/99_images/image132.png "select intelligent and click next")

  ![ ](/99_images/image133.png "select priority 1 and click next")

  ![ ](/99_images/image134.png "select priority 10 and click next")

  Click close here and don't go further

  ![ ](/99_images/image135.png "Un extended SAP resource hierarchies")

## 6. Install database Instance

  In this example, SAP NetWeaver is installed on SAP HANA. You can use every supported database for this installation. For more information on how to install SAP HANA in Azure, see High availability of SAP HANA on Azure VMs on Red Hat Enterprise Linux. For a list of supported databases, see SAP Note 1928533.

  Run the SAP database instance installation

  Install the SAP NetWeaver database instance as root using a virtual hostname that maps to the IP address of the floating hostname of the database for example s4ddb and 11.1.2.50.

  You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst.

  ```bash
  sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin
  ```

## 7. SAP NetWeaver application server installation

  Follow these steps to install an SAP application server.

  Prepare application server.

  Follow the steps in the chapter SAP NetWeaver application server preparation above to prepare the application server.

  Install SAP NetWeaver application server.

  Install a primary or additional SAP NetWeaver applications server.

  You can use the sapinst parameter SAPINST_REMOTE_ACCESS_USER to allow a non-root user to connect to sapinst.

  ```bash
  sudo <swpm>/sapinst SAPINST_REMOTE_ACCESS_USER=sapadmin
  ```

## 8. Update SAP HANA secure store

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
