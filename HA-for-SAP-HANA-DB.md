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

## Overview

To achieve high availability, SAP HANA is installed on two virtual machines. The data is replicated by using HANA System Replication.

### 2. SAP HANA DB Clustering

![HANA-DB](/99_images/DB1.png)

The following list shows the configuration of the (A)SCS and ERS IP addresses & Virtual Hostnames configured in DNS.
  |Components     | hostname     | IP address |  VIP       |  VHOSTNAME |
  | --------------| -------------|------------| -----------|----------- |
  |SAP DB Pool    | azsuhana1    | 11.1.2.51  |  11.1.2.50 |  s4ddb     |
  |               | azsuhana2    | 11.1.2.52  |            |            |
  |SIOS Witness   | azsusapwit2  | 11.1.2.66  |            |            |

## Install SAP HANA

The steps in this section use the following prefixes:

- [A]: The step applies to all nodes.
- [1]: The step applies to node 1 only.

### 1. [A] Run post-processing script ps-db.bash

### 2. [A] Run the hdblcm program from the HANA DVD. Enter the following values at the prompt:

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

### 3. [A] Upgrade the SAP Host Agent.

Download the latest SAP Host Agent archive from the SAP Software Center and run the following command to upgrade the agent. Replace the path to the archive to point to the file that you downloaded:

```code
sudo /usr/sap/hostctrl/exe/saphostexec -upgrade -archive <path to SAP Host Agent SAR>
```

## Configure SAP HANA 2.0 System Replication

- [A]: The step applies to all nodes.
- [1]: The step applies to node 1 only.

### 1. [1] Configure System Replication on the first node

Back up the databases as <hanasid>adm:

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

Register the second node to start the system replication. Run the following command as <hanasid>adm :

```code
sapcontrol -nr 00 -function StopWait 600 10
hdbnsutil -sr_register --remoteName=right --remoteHost=azsuhana2 --remoteInstance=00 --replicationMode=syncmem --operationMode=logreplay --name=left
```

![HSR status from Primary node](/99_images/image030.png)*HSR status from Primary node*
![HSR status from secondary node](/99_images/image031.png)*HSR status from a secondary node*
![Secondary System Starts after initial Sync](/99_images/image028.png)*Secondary System Starts after initial Sync*
![Replication Status in HANA Studio](/99_images/image029.png)*Replication Status in HANA Studio*

## Create SAP HANA cluster resources

### 1. [A] Setup SIOS Protection Suite - SAP HANA V2 Recovery Kit

```code
ls -ltr |grep HANA2*
```

```console
-rwxr--r-- 1 root root 24236 Feb 15 08:54 HANA2-ARK.run
```

#### 1. Run HANA2-ARK.run

```code
./HANA2-ARK.run
```

```console
Creating directory HANA2-ARK
Verifying archive integrity\... 100% All good.
Uncompressing SFX archive for SAP HANA v2 Application Recovery Kit Installation \[date: 09-22-2017\] 100%

 running /opt/LifeKeeper/HANA2-ARK/setup

Moving HANA.pm to /opt/LifeKeeper/lkadm/subsys/gen/app/bin
 -rwxr-xr-x 1 root root 9502 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
 -rwxr-xr-x 1 root root 12178 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/recover.pl
 -rwxr-xr-x 1 root root 9084 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/remove.pl
 -rwxr-xr-x 1 root root 13151 Sep 1 2017 /opt/LifeKeeper/HANA2-ARK/restore.pl

 -rwxr-xr-x 1 root root 16907 Sep 22 2017 /opt/LifeKeeper/lkadm/subsys/gen/app/bin/HANA.pm

 Installation of SAP HANA v2 Application Recovery Kit was successful
```

#### 3. Create a communication path

Login to azsuascs1 as root
start lkGUIapp

```code
/opt/LifeKeeper/bin/lkGUIapp
```

![Create communication path](/99_images/image021.png)

click comm path icon to create a communication path between all the systems in both directions. The output will look like the below screenshot

![Create communication path](/99_images/image022.png)

Note:
Please uncheck the comm path redendency warning in the view menu to see all nodes in green

## 3. SAP HANA Database Protection Configuration

### 1. Create Virtual IP for HANA DB

*Select Generic Application*
![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image032.png)

*Select Intelligent, can be changed later*

![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image033.png)
*provide the path of restore script example: /opt/LifeKeeper/ip\_genapp/restore*

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ](/99_images/image034.png)

*provide the path for remove script, example: /opt/LifeKeeper/ip\_genapp/remove*
![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image035.png)

*provide the path for quickCheck script, example : /opt/LifeKeeper/ip\_genapp/quickCheck*

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image036.png)

*provide the path for recover script, example : /opt/LifeKeeper/ip\_genapp/recover*

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image037.png)

SIOS-SUSE NIC_APP-azsuhana1 11.1.2.51 NIC_APP-azsuhana2 11.1.2.52 11.1.2.50 eth0 S4DDB

 *Provide Application info*
 ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ](/99_images/image038.png)
- *select yes*

 ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ](/99_images/image039.png)
 *provide Resource Tag ip-11.1.2.50 & click create Instance*

 ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ](/99_images/image040.png)

>- *ip recovery in progress*
>
> ![ ](/99_images/image041.png)

>- *Click next*
>
> ![ ](/99_images/image042.png)

>- *Click next*
>
> ![](/99_images/image043.png)


>- *Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image044.png)


>- *Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image045.png)

>- *Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image046.png)


>- *Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.50 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image047.png)


>- *Click next*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Resource Tag Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ](/99_images/image048.png)

>- *Click next*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Application Info \[optional\] SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC Enter any optional data for ip-11.1.2.50 that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Accept Defaults Cancel ](/99_images/image049.png)


>- *Click next*
>
> ![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch -11.1.2.50 to server azsuhana2 Extending resource instances for ip-11.1.2.50 BEGIN extend of \'lip-11.1.2.50\" END successful extend of \"ip-11.1.2.50\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (ip-11.1.2.50) Released Hierarchy successfully extended \<Back Accept Defaults ](/99_images/image050.png)


>- *Click Done*
>
> ![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ](/99_images/image051.png)




### 2. Create HANA Resource HANA-S4D

>- *Select Generic Application*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image053.png)
>- *Select intelligent*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image054.png)

```code
/opt/LifeKeeper/HANA2-ARK/restore.pl
/opt/LifeKeeper/HANA2-ARK/remove.pl
/opt/LifeKeeper/HANA2-ARK/quickCheck.pl
/opt/LifeKeeper/HANA2-ARK/recover.pl
```

for the next 4 screens please provide the following path for the scripts

 ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/HANA2-ARKJrecover.pl Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that Cancel NeKt\> ](/99_images/image055.png)

/opt/LifeKeeper/HANA2-ARK/restore.pl

/opt/LifeKeeper/HANA2-ARK/remove.pl

/opt/LifeKeeper/HANA2-ARK/quickCheck.pl

/opt/LifeKeeper/HANA2-ARK/recover.pl

Enter Application info as S4D 00 syncmem left logreplay

![Enter Application info as S4D 00 syncmem left logreplay ](/99_images/image056.png)

 Which is \<SID\> \<Instance\#\> \<replicationMode\> \<name\> \<operantionMode\>

Select Yes to bring up the service right away

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ](/99_images/image057.png)

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 HANA-S40 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ](/99_images/image058.png)*Provide a Resource tag name*

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/HANA2-ARKJrestore.pl /opt/LifeKeeper/HANA2-ARKJremove.pl HANA-S4D S4D 00 syncrnem left logreplay intelligent /opt/LifeKeeper/HANA2-ARKJquickCheck.pl /opt/LifeKeeper/HANA2-ARKJrecover.pl Yes BEGIN create of \"HANA-S40\" creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ](/99_images/image059.png)*Hierarchy creation in progress*

![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal crea eo creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal The node azsuhanal is already PRIMARY Master HANA-DB S4D 00 is already running on node azsuhanal Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhanal Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" resource \"HANA-S4D\" restored END successful create of \"HANA-S4D\" Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ](/99_images/image060.png)*Hierarchy created*

![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy HANA-S4D on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending HANA-S4D to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ](/99_images/image061.png)*Click next to pre extend check to extend the resource hierarchy to secondary node*

![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image062.png)*Click next*

![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image063.png)*Click next*

![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image064.png)*Click next*

![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for HANA-S4D Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image065.png)*Pre extend check completed successfully*

![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Resource Tag HANA-S40 Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ](/99_images/image066.png)*Provide resource tag name*

![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Application Info \[optional\] S4D 00 syncrnem right loqreplay Enter any optional data for HANA-SO that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Accept Defaults Cancel ](/99_images/image067.png)*Provide the Application info as explained in the previous screens*

![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch HANA-S4D to server azsuhana2 Extending resource instances for HANA-S4D BEGIN extend of \"HANA-S40\" END successful extend of \"HANA-S4D\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (HANA-S4D) Released Hierarchy successfully extended \<Back Accept Defaults ](/99_images/image068.png)*Click finish*

![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ](/99_images/image069.png)

*Click Done*

### 3. Create Dependency HANA DB Resource & Azure IP

 Add IP-11.1.2.50 as dependent to HANA-S4D

 *Screen clipping taken: 2/21/2019 2:49 PM*

![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ](/99_images/image070.png)
*Click Create Dependency*
![Machine generated alternative text: Create Dependency\@azsuascs2 The following dependency will be created: Parent: HANA-S40 child: ip-11.1.2.50 \<Back Cancel ](/99_images/image071.png)

*HANA-S4D dependency Tree view - move to correction location*

![Machine generated alternative text: HANA-S e ip-ll.l. In Service\... Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy\... properties\... ](/99_images/image052.png)
*Click Done*
![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent HANA-S40 of childi -11.1.2.50 Creating the dependency on the server azsuhanal Creating the dependency on the server azsuhana2 The dependency creation was successful Done ](/99_images/image072.png)
*Done*
![A screenshot of a cell phone Description automatically generated](/99_images/image073.png)
