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

 Use an terraform script from [github](https://github.com/BalaAnbalagan/SAP-on-Azure-using-Terraform) to deploy all required Azure resources, including the virtual machines, availability set etc., and in this example we are not using load balancer. You can also deploy the resources manually.

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

 download the following media from the ftp link sent by SIOS

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

### 5. Setup SIOS Enhanced Azure IP Gen Application

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

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image077.png)*c*

  ![ ](/99_images/image078.png)*d*

  ![ ](/99_images/image079.png)*e*

  ![ ](/99_images/image080.png)*f*

  ![ ](/99_images/image081.png)*g*

  The application tag provided here is very important and the values are as follows

  1. Resource Group name in Azure

  2. The NIC name in Azure for the first node

  3. The IP address for the first node

  4. The NIC name in Azure for the second node

  5. The IP address for the second node

  6. The Virtual IP address to float between the 2 nodes.

  7. The adapter used, typically eth0.

  8. Name of the IP in Azure

  SIOS-SUSE NIC_APP-azsuascs1 11.1.2.61 NIC_APP-azsuers1 11.1.2.62 11.1.2.60 eth0 S4DASCS

  ![ ](/99_images/image082.png)*h*
  
  ![ ](/99_images/image083.png)*i*

  ![ ](/99_images/image084.png)*j*

  ![ ](/99_images/image085.png)*k*

  ![ ](/99_images/image086.png)*l*

  ![ ](/99_images/image087.png)*m*

  ![ ](/99_images/image088.png)*m*

  ![ ](/99_images/image089.png)*n*

  ![ ](/99_images/image090.png)*o*

  Don not extend the resource now, please Click close

  In Azure the ip will look as shown below

  ![ ](/99_images/image091.png)*p*

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

 ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image092.png)*q*

 ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image093.png)*r*

 ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource 11.1.2.60 Enter the IP address or symbolic name to be switched by LifeKeeper. This is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. Cancel NeKt\> ](/99_images/image094.png)*s*

 ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Netmask 255.255.255.0 Enter or select a network mask for the IP resource. Any standard network mask for the class of the specified IP resource address is valid (IPv4 or IPv6 style addresses). Note: The choice of netmask, combined with the address, determines the subnet to be used by the IP resource and should be consistent with the network configuration. \<Back Cancel ](/99_images/image095.png)*t*

 ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Network Interface etho Enter or select the network interface that will be used for the IP resource being placed under LifeKeeper protection. The network interface must support the class of the IP address being protected (IPv4 or IPv6 style addresses). The default value is the first valid network interface that LifeKeeper finds on the target server that supports the class of the address being protected. Valid choices will depend on the existing network configuration and the values chosen for the IP resource address and netmask. \<Back Cancel ](/99_images/image096.png)*u*

 ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource Tag Enter a unique name that will be used to identify this IP resource instance on azsuascsl. The default tag includes the protected IP address. The valid characters allowed for the tag are letters, digits, and the following special characters: \<Back Cancel Create ](/99_images/image097.png)*v*

 ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Creatin cornm/i resource\... BEGIN create of \"vip-11.1.2.60\" LifeKeeper application---comm on azsuascsl. LifeKeeper communications resource type= ip on azsuascsl. Creating resource instance with id IR-11.1.2.60 on machine azsuascsl Resource successfully created on azsuascsl BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" END successful create of \"vip-11.1.2.60\". NeKt\> ](/99_images/image098.png)*w*

 ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy vip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending vip-11.1.2.60 to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ](/99_images/image099.png)*x*

 ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image100.png)*y*

 ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image101.png)*z*

 ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image102.png)*1*

 ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for vip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image103.png)*2*

 Don\'t extend now, click close

 Create dependency

 Add ip-11.1.2.60 as dependency to vip-11.1.2.60

 ![Machine generated alternative text: e HAN Out of Service\... e Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... ](/99_images/image104.png)*3*

 ![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ](/99_images/image105.png)*4*

 ![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent vi -11.1.2.60 of child i -11.1.2.60 Creating the dependency on the server azsuascsl The dependency creation was successful Done ](/99_images/image106.png)*5*

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

### 5. Create Data Replication Resource for ASCS mount

  ![ ](/99_images/image107.png)*6*

  ![ ](/99_images/image108.png)*7*

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image109.png)*8*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Hierarchy Type Choose the type of data replication hierarchy you wish to create: Replicate New Filesystem creates a new replicated filesystem and makes it accessible on a given mount point. Replicate Existing Filesystem converts an already mounted filesystem into a replicated filesystem. Data Replication Resource creates just a data replication device, with no associated filesystem. The filesystem (or raw disk access) must be configured manually. Cancel NeKt\> ](/99_images/image110.png)*9*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 ATTENTION! /mnt/resource is not shareable with any other server. using this choice will result in a data replication hierarchy that cannot be extended to other servers to form a shared-storage configuration. To confirm the selection of this entry press Continue. Press Back to select a different entry from the list. \<Back Cancel ](/99_images/image111.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Existing Mount Point Select the desired mount point to be replicated. The mount point must already be mounted. \<Back Cancel NeKt\> ](/99_images/image112.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 datarep-Ascsoo Data Replication Resource Tag Enter or select a unique tag name for  the data replication resource instance. \<Back Cancel ](/99_images/image113.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 File System Resource Tag usr/sap/S4D/Ascsoo Enter or select a unique tag name for the filesystem resource instance. \<Back Cancel ](/99_images/image114.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Bitmap File /LifeKeeper/bitmap usr sap\_S4D ASCSOO The bitmap file keeps a log of all changed sectors on the disk that have not yet been committed to the target(s). It is useful in the event of a network outage or system downtime because only the changed sectors need to be sent. By default, the bitmap file will contain one bit per 256KB of data on the disk (this can be changed with the LKDR CHUNK SIZE variable). Without a bitmap file, any interruption of the replication process will require a full resynchronization of all mirror targets. \<Back Cancel ](/99_images/image115.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Enable Asynchronous Replication ? no Select whether you want to enable asynchronous replication for this mirror. This is a global option for the entire mirror. Individual targets may be either synchronous or asynchronous. You must select yes if you plan to have any asynchronous targets in this mirror. You should select no if you plan to have on/y synchronous targets. Asynchronous means that writes are signalled as committed when they are safely on the source, but may still be in flight to one or more targets. Asynchronous replication requires a bitmap file. Asynchronous replication is mainly employed in WAN environments. Synchronous means that writes are only signalled as committed when they are safely on the source and all targets. With a synchronous mirror, committed transactions will not be lost even in the event of a server failure. Synchronous mirrors are mainly employed in LAN environments, where the network is fast enough to keep up with the normal write load on the protected filesystem. \<Back Cancel ](/99_images/image116.png)*10*

  ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Creatin Data Re lication Resource\... mount -t Hfs -o /dev/md0 /usr/sap/S4D/Ascsoo devicehier: using /opt/LifeKeeper/lkadm/subsys/scsi/netraid/bin/devicehier to construct the hierarchy WARNING. WARNING: WARNING: WARNING: WARNING. WARNING: WARNING: WARNING: The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. NeKt\> ](/99_images/image117.png)*10*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suasc You have successfully created the resource hierarchy datarep-ASCS00 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending datarep-ASCS00 to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ](/99_images/image118.png)*10*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image119.png)*10*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image120.png)*10*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image121.png)*10*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for datarep-ASCS00 Checking extendability for /usr/sap/S4D/ASCS00 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image122.png)*10*

  Click close and don\'t click next to extent the resource to the target side yet. The screen will be as shown below.

### 6. Create SAP Resource SAP-S4D\_ASCS00

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image123.png)*11*

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image124.png)*11*

  ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image125.png)*11*

  ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ](/99_images/image126.png)*11*

  ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ASCSOO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ](/99_images/image127.png)*11*

  ![Machine generated alternative text: Create SAP Resource\@azsuascs2 IP child resource Select the IP Address for this instance, this is typically the virtual IP address used during installation as specified by the SAPINST LJSE HOSTNAME parameter. \<Back Cancel NeKt\> ](/99_images/image128.png)*11*

  ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ASCSOO Enter the Tag name for this instance. I ate I \<Back Cancel ](/99_images/image129.png)*11*

  ![Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource.. 26.02.2019 StartWait The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function StartWait 22B 5\" command returned \"SUCCESS\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" on \"azsuascsl Please wait.. The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ASCSOO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The the and END END SAP Instance \"ASCSOO\" and all required processes were started successfully during \"restore\" on server \"azsuascsl Additional information is available in the LifeKeeper system logs. successful restore of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" successful create of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" NeKt\> ](/99_images/image130.png)*11*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy SAP-S4D ASCSOO on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending SAP-S4D ASCSOO to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ](/99_images/image131.png)*11*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image132.png)*11*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image133.png)*11*

  ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image134.png)*11*

  Click close here and don't go further

  ![Machine generated alternative text: Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ](/99_images/image135.png)*11*

### 7. Create SAP Resource SAP-S4D\_ERS10

![ ](/99_images/image136.png)*11*

![ ](/99_images/image137.png)*11*

![ ](/99_images/image138.png)*11*

![ ](/99_images/image139.png)*11*

![ ](/99_images/image140.png)*11*

![ ](/99_images/image141.png)*11*

![ ](/99_images/image142.png)*11*

![ ](/99_images/image143.png)*11*

![ ](/99_images/image144.png)*11*

![ ](/99_images/image145.png)*11*

![ ](/99_images/image146.png)*11*

![ ](/99_images/image147.png)*11*

![ ](/99_images/image148.png)*11*

![ ](/99_images/image149.png)*11*

Click accept defaults

![ ](/99_images/image150.png)*11*

![ ](/99_images/image151.png)*11*

Click finish and Done in the next screen

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

  Prepare application server

  Follow the steps in the chapter SAP NetWeaver application server preparation above to prepare the application server.

  Install SAP NetWeaver application server

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
