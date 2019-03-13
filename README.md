
# High Availability Solution for SAP NetWeaver (RHEL, OEL & SuSE*) & SAP HANA (RHEL & SuSE*)on Azure using SIOS


## 1. Introduction
> This document describes the procedure to implement High Availability solution SAP NW & SAP HANA on Azure using SIOS Protection Suite (SPS) for Linux. "SIOS Enhanced Azure Gen App" is used to switch IP address between cluster nodes instead using of Azure Internal Load balancer.
>
> The solution is certified\* for the following versions of Operating Systems

1.  Red Hat Enterprise Linux Server 7.4 (Maipo)

2.  SUSE Linux Enterprise Server 12 SP3

> Note:
>
> \*SuSE certification process in-progress
>
> The steps in this document is suitable and similar for RHEL 7.4 as well
>
> SAP installation screens not included.
>
> run sapinst with SAPINST\_USE\_HOSTNAME=\<virtual hostname\> for ASCS, ERS installations

## 2. Reference Architecture

  Components      hostname      IP address   VIP         VHOSTNAME
  --------------- ------------- ------------ ----------- -----------
  SAP ASCS Pool   azsuascs1     11.1.2.61    11.1.2.60   s4dascs
                  azsuascs2     11.1.2.62                
  SAP App Pool    azsusap1      11.1.2.53                
                  azsusap2      11.1.2.54                
  SAP DB Pool     azsuhana1     11.1.2.51    11.1.2.50   s4ddb
                  azsuhana2     11.1.2.52                
  SIOS Witness    azsusapwit1   11.1.2.65                
                  azsusapwit2   11.1.2.66                
  NFS             pg-nfs        11.1.1.11                
  DNS             pg-dns        11.1.1.5                 
  Jumpbox         pg-rdp00      11.0.1.5                 

> The reference architecture consists of the following infrastructure and key software components.

Version Table

  Components                        Release   SPS/Patch
  --------------------------------- --------- -----------
  SAP S/4 HANA                      1709      00
  SAP HANA DB                       2.0       03
  SAP Kernel                        753       300
  SIOS Protection Suite for Linux   9.3.1     
  SIOS HANA2.0 ARK                  2.0       
  SIOS Enhanced Azure Gen App       2.4       

### 1. Virtual IP & Hostnames
  
    Create the following A-Record in your DNS on similar update /etc/hosts file accordingly

    ![DNS](/99_images/image002.png)

### 2. Witness or Quorum Hosts
 

    Create 2 witness hosts, one for SAP Application Cluster and one for SAP DB Cluster.

### 3. Disk layout for ASCS Cluster Nodes
   
    Please create separate volumes/Disk for /usr/sap/ASCS00

    /dev/sdc1 /usr/sap

    /dev/sde1 /usr/sap/S4D

    /dev/sdd1 /usr/sap/S4D/ASCS00

    /dev/sdf1 /usr/sap/S4D/ERS10

    Note: The disk used for replication should be of same size

### 4. Firewall
  

    For simplicity disabled the firewall in all the nodes

### 5.  Reference Architecture Diagram
   
    ![Archtecture Diagram](/99_images/arch.png)
    This document uses SuSE landscape for illustration

## 3. Infrastructure Provisioning


> Used terraform to provision the infrastructure and used shell script to perform post processing. The source code is available in github.
>
> <https://github.com/BalaAnbalagan/HA-for-SAP-on-Azure-using-SIOS>
>
> Please run the bash post processing scripts from Github.
>
> Note:
>
> SAP HANA or SAP Installation is not part of the terraform script

## 4. SAP HA Scenario


> The SIOS Protection Suite will protect the ASCS instance and SAP will own the ERS instance.
>
> The S4D\_ASCS00 instance will have /usr/sap/S4D/ASCS00 data replication and IP Resource with Azure IP Gen App resource as child.

## 5. Azure CLI Installation for Linux
  

### 1. SuSE
       
#### 1. Install curl:

> \#sudo zypper install -y curl
![Install Curl](/99_images/image004.png)

#### 2. Import the Microsoft repository key:

> \#sudo rpm \--import <https://packages.microsoft.com/keys/microsoft.asc>
>
> \#sudo zypper addrepo \--name \'Azure CLI\' \--check <https://packages.microsoft.com/yumrepos/azure-cli> azure-cli
>
>![Import Repostory Key](/99_images/image005.png)
>
>![Addrepo Azure CLI](/99_images/image006.png)

### 2. RHEL

#### 1. Import the Microsoft repository key.

> \#sudo rpm \--import <https://packages.microsoft.com/keys/microsoft.asc>

#### 2. Create local azure-cli repository information

> \#sudo sh -c \'echo -e \"\[azure-cli\]\\nname=Azure CLI\\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\\nenabled=1\\ngpgcheck=1\\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" \> /etc/yum.repos.d/azure-cli.repo\'

#### 3.  Install with the yum install command.
```console
#sudo yum install azure-cli

Loaded plugins: langpacks, product-id, search-disabled-repos

azure-cli \| 2.9 kB 00:00:00

azure-cli/primary\_db \| 39 kB 00:00:00

Resolving Dependencies

\--\> Running transaction check

\-\--\> Package azure-cli.x86\_64 0:2.0.59-1.el7 will be installed

\--\> Finished Dependency Resolution
  

Dependencies Resolved

  
=========================================================================================================================================================================================

Package Arch Version Repository Size

=========================================================================================================================================================================================

Installing:

azure-cli x86\_64 2.0.59-1.el7 azure-cli 30 M

  

Transaction Summary

=========================================================================================================================================================================================

Install 1 Package

 

Total download size: 30 M

Installed size: 209 M

Is this ok \[y/d/N\]: y

Downloading packages:

azure-cli-2.0.59-1.el7.x86\_64.rpm \| 30 MB 00:00:00

Running transaction check

Running transaction test

Transaction test succeeded

Running transaction

Installing : azure-cli-2.0.59-1.el7.x86\_64 1/1

Verifying : azure-cli-2.0.59-1.el7.x86\_64 1/1

  

Installed:

azure-cli.x86\_64 0:2.0.59-1.el7

  

Complete!
```
#### 4. Run the login command

> \# az login
>
> To sign in, use a web browser to open the page <https://microsoft.com/devicelogin> and enter the code B7TYYXDDV to authenticate.

## 6. SIOS Protection Suite 9.3.1
>
### 1. Preparation - Only for RHEL
>
#### 1. Disable SELinux (RHEL specific)
>  
>
> \# cat /etc/selinux/config
>
>  
>
> \# This file controls the state of SELinux on the system.
>
> \# SELINUX= can take one of these three values:
>
> \# enforcing - SELinux security policy is enforced.
>
> \# permissive - SELinux prints warnings instead of enforcing.
>
> \# disabled - No SELinux policy is loaded.
>
> SELINUX=enforcing
>
> \# SELINUXTYPE= can take one of three two values:
>
> \# targeted - Targeted processes are protected,
>
> \# minimum - Modification of targeted policy. Only selected processes are protected.
>
> \# mls - Multi Level Security protection.
>
> SELINUXTYPE=targeted
>
>  
>
>  
>
`sed -i \'s/=enforcing/=disabled/\' /etc/selinux/config`
>
```console
 # cat /etc/selinux/config

 # This file controls the state of SELinux on the system.

 # SELINUX= can take one of these three values:

 # enforcing - SELinux security policy is enforced.

 # permissive - SELinux prints warnings instead of enforcing.

 # disabled - No SELinux policy is loaded.

 SELINUX=disabled

 # SELINUXTYPE= can take one of three two values:

 # targeted - Targeted processes are protected,

 # minimum - Modification of targeted policy. Only selected processes are protected.

 # mls - Multi Level Security protection.

 SELINUXTYPE=targeted
```
>  

#### 2. Reboot the VM

>  
>
> \# reboot (\* mandatory)
>
>  

#### 3. Error for SELinux 

> If SELinux is not disabled, the installation will fail with the following error
>
> ![Error - SELinux Enabled](/99_images/image007.png)

 
```console
# cat /etc/selinux/config

  

# This file controls the state of SELinux on the system.

# SELINUX= can take one of these three values:

# enforcing - SELinux security policy is enforced.

# permissive - SELinux prints warnings instead of enforcing.

# disabled - No SELinux policy is loaded.

SELINUX=disabled

# SELINUXTYPE= can take one of three two values:

# targeted - Targeted processes are protected,

# minimum - Modification of targeted policy. Only selected processes are protected.

# mls - Multi Level Security protection.

SELINUXTYPE=targeted
```
 

### 2. Setup SIOS Protection Suite -- Witness Nodes
--------------------------------------------

> \#mount /sapmedia/SIOS931/sps.img /DVD -t iso9660 -o loop

> \#./setup
>
> ![](/99_images/image008.png)
>
> ![](/99_images/image009.png)
>
> ![](/99_images/image010.png)

### 3. Setup SIOS Protection Suite - SAP Recovery Kit 

> Install SAP Recovery kit in ASCS and HANA Nodes
>
> \#./setup
>
> ![Select install License Key](/99_images/image011.png)
>
>  *Select install License Key*

> ![Enter the license path & click ok](/99_images/image012.png)

>  *Enter the license path & click ok*
>
>  ![Select Recovery kit Selection Menu](/99_images/image013.png)*Select Recovery kit Selection Menu*

 

> ![Select Application Suite](/99_images/image014.png)*Select Application Suite*

\* *


> ![Select Lifekeeper SAP Recovery kit](/99_images/image015.png)*Select Lifekeeper SAP Recovery kit*

> ![Select Lifekeeper Startup after install & Select Done](/99_images/image016.png)*Select Lifekeeper Startup after install & Select Done*

> ![Select Yes & Press Enter](/99_images/image017.png)*Select Yes & Press Enter* 

> ![](/99_images/image018.png)
>*Installation completed*
>
> ![](/99_images/image019.png) 
>*license check message*

### 4. Setup SIOS Protection Suite - SAP HANA V2 Recovery Kit

> \# ls -ltr \|grep HANA2\*
>
> -rwxr\--r\-- 1 root root 24236 Feb 15 08:54 HANA2-ARK.run

#### 1. Run HANA2-ARK.run

\# ./HANA2-ARK.run

> Creating directory HANA2-ARK
>
> Verifying archive integrity\... 100% All good.
>
> Uncompressing SFX archive for SAP HANA v2 Application Recovery Kit Installation \[date: 09-22-2017\] 100%
>
> running /opt/LifeKeeper/HANA2-ARK/setup
>
> Moving HANA.pm to /opt/LifeKeeper/lkadm/subsys/gen/app/bin
>
> -rwxr-xr-x 1 root root 9502 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
>
> -rwxr-xr-x 1 root root 12178 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/recover.pl
>
> -rwxr-xr-x 1 root root 9084 Aug 10 2017 /opt/LifeKeeper/HANA2-ARK/remove.pl
>
> -rwxr-xr-x 1 root root 13151 Sep 1 2017 /opt/LifeKeeper/HANA2-ARK/restore.pl
>
> -rwxr-xr-x 1 root root 16907 Sep 22 2017 /opt/LifeKeeper/lkadm/subsys/gen/app/bin/HANA.pm
>
> Installation of SAP HANA v2 Application Recovery Kit was successful

#### 2. verify
------

> verify the HANA.pm file copied to /opt/LifeKeeper/lkadm/subsys/gen/app/bin
>
> \# cd HANA2-ARK
>
> \# ls -ltr
>
> total 52
>
> -rwxr-xr-x 1 root root 9084 Aug 10 2017 remove.pl
>
> -rwxr-xr-x 1 root root 9502 Aug 10 2017 quickCheck.pl
>
> -rwxr-xr-x 1 root root 12178 Aug 10 2017 recover.pl
>
> -rwxr-xr-x 1 root root 13151 Sep 1 2017 restore.pl
>
> ![Check for the .pl files](/99_images/image020.png)*Check for the .pl files*

#### 3. Select lkGUIapp Node


> As per the current architecture the most expected/anticipated node to be available is azsuascs2, hence choosing it to perform the SIOS cluster configurations.

a.  Login to azsuascs1 as root

> And start lkGUIapp
>
> \#[]{#_Toc2191416 .anchor}/opt/LifeKeeper/bin/lkGUIapp
>
#### 4. Create communication path
>
> ![Create communication path](/99_images/image021.png)

 

> click comm path icon to create communication path between all the systems in both directions. The output will look like the below screenshot
>
> ![Create communication path](/99_images/image022.png)
>
> Note:
>
> Please uncheck the comm path redendency warning in the view menu to see all nodes in green

 

 

## 7. SAP HANA System Replication Configuration

### 1. Take Backup of both SYSTEMDB and Tenant DB
       

### 2. Copy keys from primary to secondary HANA nodes

> SSFS\_S4D.KEY & SSFS\_S4D.DAT from the following paths respectively
>
> /hana/shared/S4D/global/security/rsecssfs/key
>
> /hana/shared/S4D/global/security/rsecssfs/data

### 3. Enable HANA System Replication in Primary
-----------------------------------------

> \#*hdbnsutil -sr\_state*
>
> ![Current HSR state](/99_images/image023.png)
>
> *Check Current HSR state*

 

> \# hdbnsutil -sr\_enable --name=left
>
> ![Enable system replication on primary node](/99_images/image024.png)
>
> *Enable system replication on primary node*

 

 

> ![Primary HANA System Replication Enabled](/99_images/image025.png)*Primary HANA System Replication Enabled*

 

### 4. Stop HANA in secondary node before registering

>  \#hdbnsutil -sr\_register \--remoteName=left \--remoteHost=azsuhana1 \--remoteInstance=00 \--repliccationMode=syncmem \--operationMode=logreplay \--name=right
>
> ![Register Secondary node to primary node](/99_images/image026.png)
> *Register Secondary node to primary node*
>
> *Note: make sure the ini file gets updated*

### 5. Check HANA System Replication Status


>  \#hdbnsutil -sr\_state
>
>![Check the HSR state](/99_images/image027.png)
> *Check the HSR state*

> ![Secondary System Starts after initial Sync](/99_images/image028.png)*Secondary System Starts after initial Sync*

> ![Replication Status in HANA Studio](/99_images/image029.png)*Replication Status in HANA Studio*

 

> ![HSR status from Primary node](/99_images/image030.png)
>
> *HSR status from Primary node*

 

> ![HSR status from secondary node](/99_images/image031.png)
>
> *HSR status from secondary node*

## 8. SAP HANA Database Protection Configuration

### 1. Create Virtual IP for HANA DB

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image032.png)*Select Generic Application*

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image033.png)*Select Intelligent, can be changed later*

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ](/99_images/image034.png)*provide the path of restore script example: /opt/LifeKeeper/ip\_genapp/restore*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image035.png)*provide the path for remove script, example: /opt/LifeKeeper/ip\_genapp/remove*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image036.png)*provide the path for qucikCheck script, example : /opt/LifeKeeper/ip\_genapp/quickCheck*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image037.png)

 

*provide the path for recover script, example : /opt/LifeKeeper/ip\_genapp/recover*

 

SIOS-SUSE NIC\_APP-azsuhana1 11.1.2.51 NIC\_APP-azsuhana2 11.1.2.52 11.1.2.50 eth0 S4DDB

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ](/99_images/image038.png)

 

*Provide Application info*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ](/99_images/image039.png)*Screen clipping taken: 2/21/2019 11:58 AM*

 

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ](/99_images/image040.png)*Screen clipping taken: 2/21/2019 2:43 PM*

 

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/ip\_genapp/restore /opt/LifeKeeper/ip\_genapp/remove ip-11.1.2.50 SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC APP-azsuhana2 11.1.2.52 11.1.2.50 etho S4DDB intelligent /opt/LifeKeeper/ip\_genapp/quickCheck /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ](/99_images/image041.png)*Screen clipping taken: 2/21/2019 2:44 PM*

 

 

\* *

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal In e lgen op e eeper Ip\_genapp quic /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes INFORMATION: END successful restore of ip-11.1.2.50 on azsuhanal END successful restore of \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" restored END successful create of \"ip-11.1.2.50\" Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ](/99_images/image042.png)*Screen clipping taken: 2/21/2019 2:45 PM*

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suhana2 You have successfully created the resource hierarchy ip-11.1.2.50 on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.50 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ](/99_images/image043.png)*Screen clipping taken: 2/21/2019 2:45 PM*

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image044.png)*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image045.png)*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image046.png)*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.50 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image047.png)*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Resource Tag Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ](/99_images/image048.png)*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Application Info \[optional\] SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC Enter any optional data for ip-11.1.2.50 that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Accept Defaults Cancel ](/99_images/image049.png)*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch -11.1.2.50 to server azsuhana2 Extending resource instances for ip-11.1.2.50 BEGIN extend of \'lip-11.1.2.50\" END successful extend of \"ip-11.1.2.50\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (ip-11.1.2.50) Released Hierarchy successfully extended \<Back Accept Defaults ](/99_images/image050.png)*Screen clipping taken: 2/21/2019 2:48 PM*

 

 

> ![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ](/99_images/image051.png)*Screen clipping taken: 2/21/2019 2:48 PM*

 

 

> ![Machine generated alternative text: HANA-S e ip-ll.l. In Service\... Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy\... properties\... ](/99_images/image052.png)
>
> *Screen clipping taken: 2/21/2019 2:49 PM*

 

 

### 2. Create HANA Resource HANA-S4D


> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image053.png)*Select Generic Application*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image054.png)*Select intelligent*
>
> /opt/LifeKeeper/HANA2-ARK/restore.pl
>
> /opt/LifeKeeper/HANA2-ARK/remove.pl
>
> /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
>
> /opt/LifeKeeper/HANA2-ARK/recover.pl
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/HANA2-ARKJrecover.pl Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that Cancel NeKt\> ](/99_images/image055.png)*for the next 4 screens please provide the following path for the scripts*
>
> /opt/LifeKeeper/HANA2-ARK/restore.pl
>
> /opt/LifeKeeper/HANA2-ARK/remove.pl
>
> /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
>
> /opt/LifeKeeper/HANA2-ARK/recover.pl
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] S4D 00 syncrnem left loqreplay Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Cancel ](/99_images/image056.png)*Enter Application info as S4D 00 syncmem left logreplay*
>
> Which is \<SID\> \<Instance\#\> \<replicationMode\> \<name\> \<operantionMode\>
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ](/99_images/image057.png)*Select Yes to bring up the service right away*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 HANA-S40 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ](/99_images/image058.png)*Provide a Resource tag name*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/HANA2-ARKJrestore.pl /opt/LifeKeeper/HANA2-ARKJremove.pl HANA-S4D S4D 00 syncrnem left logreplay intelligent /opt/LifeKeeper/HANA2-ARKJquickCheck.pl /opt/LifeKeeper/HANA2-ARKJrecover.pl Yes BEGIN create of \"HANA-S40\" creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ](/99_images/image059.png)*Hierarchy creation in progress*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal crea eo creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal The node azsuhanal is already PRIMARY Master HANA-DB S4D 00 is already running on node azsuhanal Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhanal Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" resource \"HANA-S4D\" restored END successful create of \"HANA-S4D\" Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ](/99_images/image060.png)*Hierarchy created*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy HANA-S4D on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending HANA-S4D to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ](/99_images/image061.png)*Click next to pre extend check to extend the resource hierarchy to secondary node*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image062.png)*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image063.png)*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image064.png)*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for HANA-S4D Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image065.png)*Pre extend check completed successfully*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Resource Tag HANA-S40 Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ](/99_images/image066.png)*Provide resource tag name*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Application Info \[optional\] S4D 00 syncrnem right loqreplay Enter any optional data for HANA-SO that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Accept Defaults Cancel ](/99_images/image067.png)*Provide the Application info as explained in the previous screens*
>
> ![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch HANA-S4D to server azsuhana2 Extending resource instances for HANA-S4D BEGIN extend of \"HANA-S40\" END successful extend of \"HANA-S4D\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (HANA-S4D) Released Hierarchy successfully extended \<Back Accept Defaults ](/99_images/image068.png)*Click finish*
>
> ![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ](/99_images/image069.png)
>
> *Click Done*

### 3. Create Dependency HANA DB Resource & Azure IP

> Add IP-11.1.2.50 as dependent to HANA-S4D
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ](/99_images/image070.png)*Screen clipping taken: 2/21/2019 2:49 PM*


> ![Machine generated alternative text: Create Dependency\@azsuascs2 The following dependency will be created: Parent: HANA-S40 child: ip-11.1.2.50 \<Back Cancel ](/99_images/image071.png)
>
> *Click Create Dependency*

 

 

> ![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent HANA-S40 of childi -11.1.2.50 Creating the dependency on the server azsuhanal Creating the dependency on the server azsuhana2 The dependency creation was successful Done ](/99_images/image072.png)*Click Done*

 

> ![A screenshot of a cell phone Description automatically generated](/99_images/image073.png)*Screen clipping to show the dependency tree created*

 

## 9. Install SAP Components
> Please follow SAP installation procedure with the recommended settings mentioned in each type of installation

### 1. Install SAP (A) System Central Server on Node1 

> Add virtual hostname and IP address in /etc/host file
>
> 11.1.2.60 s4dascs
>
> \#./sapinst SAPINST\_USE\_HOSTNAME=s4dascs

### 2. Install SAP Enqueue Replication Server on Node 1

> \#./sapinst SAPINST\_USE\_HOSTNAME=s4ders (not protected/ no failover)

### 3. Install Primary Application Server


> Make sure you give DBHOST name as virtual hostname s4ddb (11.1.2.50)
>
> Check hdbuserstore after PAS installation
>
> azsusap1:s4dadm 53\> hdbuserstore list
>
> DATA FILE : /home/s4dadm/.hdb/azsusap1/SSFS\_HDB.DAT
>
> KEY FILE : /home/s4dadm/.hdb/azsusap1/SSFS\_HDB.KEY
>
> KEY DEFAULT
>
> ENV : s4ddb.provingground.net:30013
>
> USER: S4HABAP
>
> DATABASE: S4D
>
> azsusap1:s4dadm 54\>

### 4. Install Addition Application Server (optional)


## 10. SAP ASCS/ERS cluster configuration


### 1. Create floating IP for ASCS
        ---------------------------

> In this step we are creating Enhanced Azure GenApp resource which will create the secondary ip address on the node using azure cli which we installed in earlier step.
>
> The cli command used will be as follows
>
> az network nic ip-config create \--resource-group SIOS-SUSE \--nic-name NIC\_APP-azsuascs1 \--private-ip-address 11.1.2.60 \--name S4DASCS
>
> remove virtual hostname and IP address in /etc/host file 11.1.2.60 s4dascs
>
> ![Machine generated alternative text: Eile Edit Yiew Help ](/99_images/image074.png)
>
> Click + icon to create resource hierarchy
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image075.png)*a*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image076.png)*b*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image077.png)*c*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ](/99_images/image078.png)*d*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image079.png)*e*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image080.png)*f*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ](/99_images/image081.png)*g*
>
> The application tag provided here is very important and the values are as follows
>
> 1\. Resource Group name in Azure
>
> 2\. The NIC name in Azure for the first node
>
> 3\. The IP address for the first node
>
> 4\. The NIC name in Azure for the second node
>
> 5\. The IP address for the second node
>
> 6\. The Virtual IP address to float between the 2 nodes.
>
> 7\. The adapter used, typically eth0.
>
> 8\. Name of the IP in Azure
>
> SIOS-SUSE NIC\_APP-azsuascs1 11.1.2.61 NIC\_APP-azsuers1 11.1.2.62 11.1.2.60 eth0 S4DASCS
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 SIOS-SUSE NIC APP-azsuascsl 11.1.2.61 NIC Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ](/99_images/image082.png)*h*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ](/99_images/image083.png)*i*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuascsl. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ](/99_images/image084.png)*j*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.60 on azsuascsl op e eeper Ip\_genapp recover es BEGIN create of \'lip-11.1.2.60\" creating resource \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" successfully created restoring resource \"ip-11.1.2.60\" BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascsl Note: This process could take up to 2 minutes RTNETLINK answers: File exists INFORMATION: END successful restore of ip-11.1.2.60 on azsuascsl END successful restore of \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" restored END successful create of \"ip-11.1.2.60\" Messages produced while creating ip-11.1.2.60 will be displayed in this dialog and the output panel (if open), and logged on azsuascsl. NeKt\> ](/99_images/image085.png)*k*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy ip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.60 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ](/99_images/image086.png)*l*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image087.png)*m*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image088.png)*m*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image089.png)*n*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image090.png)*o*
>
> Don\'t extend now Click close
>
> In Azure the ip will look as shown below
>
> ![A screenshot of a social media post Description automatically generated](/99_images/image091.png)*p*
>
> In linux the secondary ip address will be added to the eth0 device
>
> azsuascs1:\~ \# ip add show
>
> 1: lo: \<LOOPBACK,UP,LOWER\_UP\> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
>
> link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
>
> inet 127.0.0.1/8 scope host lo
>
> valid\_lft forever preferred\_lft forever
>
> inet6 ::1/128 scope host
>
> valid\_lft forever preferred\_lft forever
>
> 2: eth0: \<BROADCAST,MULTICAST,UP,LOWER\_UP\> mtu 1500 qdisc mq state UP group default qlen 1000
>
> link/ether 00:0d:3a:06:27:29 brd ff:ff:ff:ff:ff:ff
>
> inet 11.1.2.61/24 brd 11.1.2.255 scope global eth0
>
> valid\_lft forever preferred\_lft forever
>
> inet 11.1.2.60/24 scope global secondary eth0
>
> valid\_lft forever preferred\_lft forever
>
> inet6 fe80::20d:3aff:fe06:2729/64 scope link
>
> valid\_lft forever preferred\_lft forever
>
>  

### 2. Create IP Resource Kit


> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image092.png)*q*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image093.png)*r*
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource 11.1.2.60 Enter the IP address or symbolic name to be switched by LifeKeeper. This is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. Cancel NeKt\> ](/99_images/image094.png)*s*
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Netmask 255.255.255.0 Enter or select a network mask for the IP resource. Any standard network mask for the class of the specified IP resource address is valid (IPv4 or IPv6 style addresses). Note: The choice of netmask, combined with the address, determines the subnet to be used by the IP resource and should be consistent with the network configuration. \<Back Cancel ](/99_images/image095.png)*t*
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Network Interface etho Enter or select the network interface that will be used for the IP resource being placed under LifeKeeper protection. The network interface must support the class of the IP address being protected (IPv4 or IPv6 style addresses). The default value is the first valid network interface that LifeKeeper finds on the target server that supports the class of the address being protected. Valid choices will depend on the existing network configuration and the values chosen for the IP resource address and netmask. \<Back Cancel ](/99_images/image096.png)*u*
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource Tag Enter a unique name that will be used to identify this IP resource instance on azsuascsl. The default tag includes the protected IP address. The valid characters allowed for the tag are letters, digits, and the following special characters: \<Back Cancel Create ](/99_images/image097.png)*v*
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Creatin cornm/i resource\... BEGIN create of \"vip-11.1.2.60\" LifeKeeper application---comm on azsuascsl. LifeKeeper communications resource type= ip on azsuascsl. Creating resource instance with id IR-11.1.2.60 on machine azsuascsl Resource successfully created on azsuascsl BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" END successful create of \"vip-11.1.2.60\". NeKt\> ](/99_images/image098.png)*w*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy vip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending vip-11.1.2.60 to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ](/99_images/image099.png)*x*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image100.png)*y*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image101.png)*z*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image102.png)*1*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for vip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image103.png)*2*
>
> Don\'t extend now, click close
>
> Create dependency
>
> Add ip-11.1.2.60 as dependency to vip-11.1.2.60
>
> ![Machine generated alternative text: e HAN Out of Service\... e Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... ](/99_images/image104.png)*3*
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ](/99_images/image105.png)*4*
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent vi -11.1.2.60 of child i -11.1.2.60 Creating the dependency on the server azsuascsl The dependency creation was successful Done ](/99_images/image106.png)*5*

### 3. Create Data Replication Resource for ASCS mount
-----------------------------------------------

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image107.png)*6*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image108.png)*7*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image109.png)*8*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Hierarchy Type Choose the type of data replication hierarchy you wish to create: Replicate New Filesystem creates a new replicated filesystem and makes it accessible on a given mount point. Replicate Existing Filesystem converts an already mounted filesystem into a replicated filesystem. Data Replication Resource creates just a data replication device, with no associated filesystem. The filesystem (or raw disk access) must be configured manually. Cancel NeKt\> ](/99_images/image110.png)*9*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 ATTENTION! /mnt/resource is not shareable with any other server. using this choice will result in a data replication hierarchy that cannot be extended to other servers to form a shared-storage configuration. To confirm the selection of this entry press Continue. Press Back to select a different entry from the list. \<Back Cancel ](/99_images/image111.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Existing Mount Point Select the desired mount point to be replicated. The mount point must already be mounted. \<Back Cancel NeKt\> ](/99_images/image112.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 datarep-Ascsoo Data Replication Resource Tag Enter or select a unique tag name for the data replication resource instance. \<Back Cancel ](/99_images/image113.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 File System Resource Tag usr/sap/S4D/Ascsoo Enter or select a unique tag name for the filesystem resource instance. \<Back Cancel ](/99_images/image114.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Bitmap File /LifeKeeper/bitmap usr sap\_S4D ASCSOO The bitmap file keeps a log of all changed sectors on the disk that have not yet been committed to the target(s). It is useful in the event of a network outage or system downtime because only the changed sectors need to be sent. By default, the bitmap file will contain one bit per 256KB of data on the disk (this can be changed with the LKDR CHUNK SIZE variable). Without a bitmap file, any interruption of the replication process will require a full resynchronization of all mirror targets. \<Back Cancel ](/99_images/image115.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Enable Asynchronous Replication ? no Select whether you want to enable asynchronous replication for this mirror. This is a global option for the entire mirror. Individual targets may be either synchronous or asynchronous. You must select yes if you plan to have any asynchronous targets in this mirror. You should select no if you plan to have on/y synchronous targets. Asynchronous means that writes are signalled as committed when they are safely on the source, but may still be in flight to one or more targets. Asynchronous replication requires a bitmap file. Asynchronous replication is mainly employed in WAN environments. Synchronous means that writes are only signalled as committed when they are safely on the source and all targets. With a synchronous mirror, committed transactions will not be lost even in the event of a server failure. Synchronous mirrors are mainly employed in LAN environments, where the network is fast enough to keep up with the normal write load on the protected filesystem. \<Back Cancel ](/99_images/image116.png)*10*
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Creatin Data Re lication Resource\... mount -t Hfs -o /dev/md0 /usr/sap/S4D/Ascsoo devicehier: using /opt/LifeKeeper/lkadm/subsys/scsi/netraid/bin/devicehier to construct the hierarchy WARNING. WARNING: WARNING: WARNING: WARNING. WARNING: WARNING: WARNING: The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. NeKt\> ](/99_images/image117.png)*10*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suasc You have successfully created the resource hierarchy datarep-ASCS00 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending datarep-ASCS00 to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ](/99_images/image118.png)*10*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image119.png)*10*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image120.png)*10*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image121.png)*10*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for datarep-ASCS00 Checking extendability for /usr/sap/S4D/ASCS00 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ](/99_images/image122.png)*10*
>
> Click close and don\'t click next to extent the resource to the target side yet. The screen will be as shown below.

### 4. Create SAP Resource SAP-S4D\_ASCS00


> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image123.png)*11*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image124.png)*11*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ](/99_images/image125.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ](/99_images/image126.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ASCSOO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ](/99_images/image127.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 IP child resource Select the IP Address for this instance, this is typically the virtual IP address used during installation as specified by the SAPINST LJSE HOSTNAME parameter. \<Back Cancel NeKt\> ](/99_images/image128.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ASCSOO Enter the Tag name for this instance. I ate I \<Back Cancel ](/99_images/image129.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource.. 26.02.2019 StartWait The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function StartWait 22B 5\" command returned \"SUCCESS\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" on \"azsuascsl Please wait.. The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ASCSOO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The the and END END SAP Instance \"ASCSOO\" and all required processes were started successfully during \"restore\" on server \"azsuascsl Additional information is available in the LifeKeeper system logs. successful restore of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" successful create of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" NeKt\> ](/99_images/image130.png)*11*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy SAP-S4D ASCSOO on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending SAP-S4D ASCSOO to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ](/99_images/image131.png)*11*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ](/99_images/image132.png)*11*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ](/99_images/image133.png)*11*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ](/99_images/image134.png)*11*
>
> Click close here and don't go further
>
> ![Machine generated alternative text: Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ](/99_images/image135.png)*11*

### 5. Create SAP Resource SAP-S4D\_ERS10


> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsu Disconnect\... Refresh.. View Logs\... Create Resource Hierarchy\... Create Comm Path\... Delete Comm Path\... properties\... azsuascs2 ](/99_images/image136.png)*11*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ](/99_images/image137.png)*11*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ](/99_images/image138.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ](/99_images/image139.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ERSIO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ](/99_images/image140.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 AP-S4D ASCSOO Select dependent instances Select the Dependent Central Instance for this application instance, ERSIO. This will create a dependency. \<Back NeKt\> Cancel ](/99_images/image141.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ERSIO Enter the Tag name for this instance. I ate I \<Back Cancel ](/99_images/image142.png)*11*
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource\... Preparing to run the command: \"/usr/sap/hostctrl/exe/saphostexec -status\" on \"azsuascsl Please wait\... start hostcontrol using profile /usr/sap/hostctrl/exe/host\_profile saphostexec running (pid = 3130) sapstartsrv running (pid = 3315) saposcol running (pid = 3379) The command \"/usr/sap/hostctrl/exe/saphostexec\" is running on \"azsuascsl Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascsl Please wait\... Warning the profile file /usr/sap/S4D/ERS10/profile/S4D ERSIO s4ders for SID S4D and Instance ERSIO has Autostart is enabled on azsuascsl. Disable Autostart for the specified instance by setting Autostart=0 in the profile file There are no equivalent systems available to perform the \"isSAPRKSRunning\" action for the Replicate Enqueue Instance \"ERSIO\" on \"azsuascsl The resource must be extended to at most one server before this operation can complete END successful restore of \"SAP-S4D ERSIO\" on server \"azsuascsl \" END successful create of \"SAP-S4D ERSIO\" on server \"azsuascsl \" NeKt\> ](/99_images/image143.png)*11*
>
> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e vip-11.1.2.60 e /usr/sap/S4D/Ascsoo HANA-S40 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ](/99_images/image144.png)*11*
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Target Disk Select a disk on azsuascs2. The selection must not be mounted and must be at least as large as the source disk on azsuascsl. Accept Defaults Cancel NeKt\> ](/99_images/image145.png)*11*
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Data Replication Resource Tag datarep-Ascsoo Enter or select a unique tag name for the data replication \<Back Accept Defaults Cancel resource instance. ](/99_images/image146.png)*11*
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Data Replication Resource Tag datarep-Ascsoo Enter or select a unique tag name for the data replication \<Back Accept Defaults Cancel resource instance. ](/99_images/image147.png)*11*
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Replication Path Select the network end points to be used for replication between systems azsuascsl and azsuascs2. \<Back NeKt\> Accept Defaults Cancel ](/99_images/image148.png)*11*
>
> ![Machine generated alternative text: Extend comm/ip Resource Hierarchy\@azsuascs2 Template Server: azsuascsl Tag to Extend: vip-11.1.2.60 Target Server: azsuascs2 IP Resource The IP address or symbolic name to be protected by the IP resource on the target server. The same value that was used on the template server is used for the IP resource on the target server. Therefore, this value cannot be changed. The IP resource is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. NeKt\> Accept Defaults Cancel ](/99_images/image149.png)*11*
>
> Click accept defaults
>
> ![Machine generated alternative text: Eile Edit Yiew Help Hierarchies Not Active datarep-Ascsoo SAP-S4D ASCSOO SAP-S4D ERSIO vip-11.1.2.60 SAP-S4D ERSIO azsusapwitl azsusapwit2 azsuascsl azsuascs2 azsuhanal azsuhana2 ](/99_images/image150.png)*11*
>
> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 azsusapwitl azsusapwit2 Extend Wizard\@azsuascs2 azsuascsl azsuascs2 azsuhanal azsuhana2 Extendin resource hierarch -11.1.2.60 to server azsuascs2 Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/create\_ins\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/depstoeHtend\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/genftilesys/bin/eHtend\" on \"azsuascs2\". Please wait\... BEGIN extend of \'lip-11.1.2.60\" END successful extend of \"ip-11.1.2.60\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (SAP-S4D ERSIO) Released Hierarchy successfully extended Next Server Accept Defaults ](/99_images/image151.png)*11*
>
> Click finish and Done in the next screen

## 11.SIOS Failover Testing

### 1. SAP HANA Database Failover

> ![Machine generated alternative text: Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S In Service.. e ip-l Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ](/99_images/image152.png)*12*

> ![Machine generated alternative text: InService\@azsuascs2 NeKt\> Cancel ](/99_images/image153.png)*12*
 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 Confirm in service action for Server: azsuhana2 Resource: HANA-S40 azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 \<Back Cancel ](/99_images/image154.png)*12*


![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service Done azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ](/99_images/image155.png)*12*
 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--private-ip-address 11.1.2.50 azsuhanal azsuhana2 e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhana2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.50 on azsuhana2 END successful restore of \"ip-11.1.2.50\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Done \--nic-name NIC APP-azsuhana2 \--name ipconfig2 \> /dev/null 2\>&1) on azsuhanal ](/99_images/image156.png)*12*


![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 Brin in HANA-S4D in service on azsuhana2 SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Node azsuhana2 is now PRIMARY master Takeover of System Replication finished successful on node azsuhana2 HANA-DB S4D 00 is already running on node azsuhana2 DEBUG\[0524\]: getRemoteHostParmName: set profileHostName=azsuhana2. dflt=azsuhana2 Replication mode on node azsuhanal is now syncrnem Reenable system replication on node azsuhanal finished successful Node azsuhanal is now registered in system replication mode syncrnem at node azsuhana2 SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Starting HANA-DB S4D 00 on node azsuhanal Start of HANA-DB S4D 00 on node azsuhanal successful Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhana2 Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" Put \"HANA-S4D\" in-service successful Done ](/99_images/image157.png)*12*



### 2. SAP ASCS Failover

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D SAP-S e e HANA-S4 update Protection Level update Recoveru Level Handle Warnings SSCC HA Actions In Service\... Out of Service\... Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy.. properties\... ](/99_images/image158.png)*12*


![Machine generated alternative text: InService\@azsuascs2 NeKt\> Cancel ](/99_images/image159.png)*12*


![Machine generated alternative text: n Service\@azsuascs2 Confirm in service action for Server: azsuascs2 Resource: SAP-S4D ERSIO (SAPID-S40-ERSIO) \<Back Cancel ](/99_images/image160.png)*12*

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS Done ](/99_images/image161.png)*12*


![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Done ](/99_images/image162.png)*12*


![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--name S4DASCS \> /dev/null 2\>&1) on azsuascsl azsuhanal azsuhana2 e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.60 on azsuascs2 END successful restore of \"ip-11.1.2.60\" BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" Done \--nic-name NIC APP-azsuersl \--private-ip-address 11.1.2.60 ](/99_images/image163.png)*Successfully Tested Failover: 2/21/2019 11:51 AM*
 

 



 

 

## 12. Lesson's learned

