+-----------------------------------------------------------------------------+
| Microsoft                                                                   |
+=============================================================================+
| High Availability Solution for SAP NetWeaver & SAP HANA on Azure using SIOS |
+-----------------------------------------------------------------------------+
| -   for RHEL, OEL & SUSE Linux                                              |
+-----------------------------------------------------------------------------+


Contents {#contents .TOCHeading}
========

[1. Introduction 4]

[2. Reference Architecture 4]

[2.1 Virtual IP & Hostnames 5]

[2.2 Witness or Quorum Hosts 5]

[2.3 Disk layout for ASCS Cluster Nodes 5]

[2.4 Firewall 5]

[2.5 Reference Architecture Diagram 5]

[3. SAP HA Scenario 6]

[4. Azure CLI Installation for Linux 7]

[4.1 SuSE 7]

[4.1.1 Install curl: 7]

[4.1.2 Import the Microsoft repository key: 7]

[4.2 RHEL 7]

[4.2.1 Import the Microsoft repository key. 7]

[4.2.2 Create local azure-cli repository information 8]

[4.2.3 Install with the yum install command. 8]

[4.2.4 Run the login command 9]

[5. SIOS Protection Suite 9.3.1 9]

[5.1 Preparation - Only for RHEL 9]

[5.2 Setup SIOS Protection Suite -- Witness Nodes 10]

[5.3 Setup SIOS Protection Suite - SAP Recovery Kit 12]

[5.4 Setup SIOS Protection Suite - SAP HANA V2 Recovery Kit 16]

[5.4.1 Run HANA2-ARK.run 16]

[5.4.2 verify 16]

[5.4.3 Select lkGUIapp Node 16]

[5.4.4 Create communication path 16]

[8. SAP HANA System Replication Configuration 16]

[9. SAP HANA Database Protection Configuration 16]

[9.1 Create Virtual IP for HANA DB 16]

[9.2 Create HANA Resource HANA-S4D 17]

[9.3 Create Dependency HANA DB Resource & Azure IP 27]

[10. Install SAP Components 29]

[10.1 Install SAP (A) System Central Server 29]

[10.2 Install SAP Enqueue Replication Server 29]

[10.3 Install Primary Application Server 29]

[10.4 Install Addition Application Server (optional) 30]

[11. SAP ASCS/ERS cluster configuration 30]

[11.1 Create floating IP for ASCS 30]

[11.2 Create IP Resource Kit 40]

[11.3 Create Data Replication Resource for ASCS mount 40]

[11.4 Create SAP Resource SAP-S4D\_ASCS00 40]

[11.5 Create SAP Resource SAP-S4D\_ERS10 40]

[12. SIOS Failover Testing 40]

[12.1 SAP HANA Database Failover 40]

[12.2 SAP ASCS Failover 40]

[13. Lesson's learned 40]

Introduction
============

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

Reference Architecture
======================

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

1.  Virtual IP & Hostnames
    ----------------------

    Create the following A-Record in your DNS on similar update /etc/hosts file accordingly

    ![A screenshot of a social media post Description automatically generated]

2.  Witness or Quorum Hosts
    -----------------------

    Create 2 witness hosts, one for SAP Application Cluster and one for SAP DB Cluster.

3.  Disk layout for ASCS Cluster Nodes
    ----------------------------------

    Please create separate volumes/Disk for /usr/sap/ASCS00

    /dev/sdc1 /usr/sap

    /dev/sde1 /usr/sap/S4D

    /dev/sdd1 /usr/sap/S4D/ASCS00

    /dev/sdf1 /usr/sap/S4D/ERS10

    Note: The disk used for replication should be of same size

4.  Firewall
    --------

    For simplicity disabled the firewall in all the nodes

5.  Reference Architecture Diagram
    ------------------------------

This document uses SuSE landscape for illustration

Infrastructure Provisioning
===========================

> Used terraform to provision the infrastructure and used shell script to perform post processing. The source code is available in github.
>
> <https://github.com/BalaAnbalagan/HA-for-SAP-on-Azure-using-SIOS>
>
> Please run the bash post processing scripts from Github.
>
> Note:
>
> SAP HANA or SAP Installation is not part of the terraform script

SAP HA Scenario
===============

> The SIOS Protection Suite will protect the ASCS instance and SAP will own the ERS instance.
>
> The S4D\_ASCS00 instance will have /usr/sap/S4D/ASCS00 data replication and IP Resource with Azure IP Gen App resource as child.

5.  Azure CLI Installation for Linux
    ================================

    6.  SuSE
        ----

        1.  ### Install curl:

> \#sudo zypper install -y curl![azsuhanal:--- \# sudo zypper install -y curl Refreshing service \'SMT-http\_smt-azure\_susecIoud\_net• . Refreshing service •cloud \_ update\' . Retrieving repository \'SLE-Module-pubIic-C10ud12-Updates• metadata Building repository \'SLE-Module-pub1ic-C10ud12-Updates• cache Retrieving repository \'SLE-SDK12-SP3-Updates• metadata Building repository \'SLE-SDK12-SP3-Updates• cache . Retrieving repository \'SLES12-SP3-Updates• metadata Building repository \'SLES12-SP3-Updates• cache Loading repository data. Reading installed packages . . Resolving package dependencies. . The following package is going to be upgraded: curl 1 package to upgrade . Overall download size: 153.4 KiB. Already cached: Continue? \[yin/ . ? shows all options\] (y): Y Retrieving package curl-7.37.0-37.31.1. x86 64 Retrieving: curl-7.37.0-37.31.1.x86 64. rpm Checking for file conflicts : (1/1) Installing: curl-7.37.e-37.31.1.x86 64 azsuhanal:--- \# e B. additional space will be used or f reed after the ope ration . (1/1), . \[done\] . \[done\] . \[done\] . \[done\] . \[done\] . \[done\] 153.4 KiB (312.9 KiB unpacked) . \[done\] . \[done\] . \[done\] ]

### Import the Microsoft repository key:

> \#sudo rpm \--import <https://packages.microsoft.com/keys/microsoft.asc>
>
> \#sudo zypper addrepo \--name \'Azure CLI\' \--check <https://packages.microsoft.com/yumrepos/azure-cli> azure-cli
>
>  
>
> ![\*zsuhanal:--- \*zsuhanal:--- sudo rpm - -Import https ://packages.mlcrosott.com/keys/mlcrosott . asc \# sudo zypper add repo -check https://packages.mlcrosoft . com/yumrepos/azure-cli azure-cli -name \'Azure CLI\' Xdding repository \'Azure CLI\' {epository \'Azure CLI\' successfully added https : //packages . mic rosoft . com/yumrepos/azure-cli . \[done\] Enabled 3PG Check W to refresh \'rlority Yes Yes 99 (default priority) {epository priorities are without effect . \*zsuhanal:--- \# All enabled repositories share the same priority. ]*Screen clipping taken: 12/19/2018 4:07 PM*
>
>  
>
>  
>
> ![azsuhanal:--- sudo zypper addrepo -name Adding repository \'Azure CLI\' Repository \'Azure CLI\' successfully added \'Azure CLI\' https://packages.mlcrosott . com/yumrepos/azure-cll azure-cL1 Enabled GPG Check Auto ref resh priority https : //packages . mic rosoft . com/yumrepos/azure-cli Yes 99 (default priority) Repository priorities are without effect. All enabled azsuhanal:--- \# sudo zypper install -from azure-cli -y Refreshing service \'SMT-http\_smt-azure\_susecIoud\_net\' . Refreshing service •cloud \_ update\' . Building repository \'Azure CLI\' cache Loading repository data. Reading installed packages. . . Resolving package dependencies . . . The following NEW package is going to be installed: azure-cli The following package has no support information from azure-cli 1 new package to install. Overall download size: 25.1 MiB. Already cached: € B. Continue? \[yin/ . ? shows all options\] (y): Y Retrieving package azure-cli-2.e.53-1.e17. x86 64 Retrieving: azure-cli-2.€.53-1.e17.x86 64. rpm Checking for file conflicts : (1/1) Installing: azure-cli-2.€.53-1.e17. x86 64 azsuhanal:--- \# repositories share the same priority. azure-cli it\'s vendor: After the operation, additional 177 .5 Mie will be used . (1/1), . \[done\] . \[done\] 25.1 Mie (177.5 Mie unpacked) . \[done\] . \[done\] . \[done\] ]*Screen clipping taken: 12/19/2018 4:08 PM*

7.  RHEL
    ----

    3.  ### Import the Microsoft repository key.

> \#sudo rpm \--import <https://packages.microsoft.com/keys/microsoft.asc>

### Create local azure-cli repository information

> \#sudo sh -c \'echo -e \"\[azure-cli\]\\nname=Azure CLI\\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\\nenabled=1\\ngpgcheck=1\\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc\" \> /etc/yum.repos.d/azure-cli.repo\'

### Install with the yum install command.

> \#sudo yum install azure-cli
>
> Loaded plugins: langpacks, product-id, search-disabled-repos
>
> azure-cli \| 2.9 kB 00:00:00
>
> azure-cli/primary\_db \| 39 kB 00:00:00
>
> Resolving Dependencies
>
> \--\> Running transaction check
>
> \-\--\> Package azure-cli.x86\_64 0:2.0.59-1.el7 will be installed
>
> \--\> Finished Dependency Resolution
>
>  
>
> Dependencies Resolved
>
>  
>
> =========================================================================================================================================================================================
>
> Package Arch Version Repository Size
>
> =========================================================================================================================================================================================
>
> Installing:
>
> azure-cli x86\_64 2.0.59-1.el7 azure-cli 30 M
>
>  
>
> Transaction Summary
>
> =========================================================================================================================================================================================
>
> Install 1 Package
>
>  
>
> Total download size: 30 M
>
> Installed size: 209 M
>
> Is this ok \[y/d/N\]: y
>
> Downloading packages:
>
> azure-cli-2.0.59-1.el7.x86\_64.rpm \| 30 MB 00:00:00
>
> Running transaction check
>
> Running transaction test
>
> Transaction test succeeded
>
> Running transaction
>
> Installing : azure-cli-2.0.59-1.el7.x86\_64 1/1
>
> Verifying : azure-cli-2.0.59-1.el7.x86\_64 1/1
>
>  
>
> Installed:
>
> azure-cli.x86\_64 0:2.0.59-1.el7
>
>  
>
> Complete!

### Run the login command

> \# az login
>
> To sign in, use a web browser to open the page <https://microsoft.com/devicelogin> and enter the code B7TYYXDDV to authenticate.

6.  SIOS Protection Suite 9.3.1
    ===========================

    8.  Preparation - Only for RHEL
        ---------------------------

        7.  #### Disable SELinux (RHEL specific)

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
> \# sed -i \'s/=enforcing/=disabled/\' /etc/selinux/config
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
> SELINUX=disabled
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

#### Reboot the VM

>  
>
> \# reboot (\* mandatory)
>
>  

#### Error for SELinux 

> If SELinux is not disabled, the installation will fail with the following error
>
> ![Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup pre-lnstall check failed: : SELinux appears to be enabled. please disable SELinux before installing SPS for Linux. ]*Screen clipping taken: 2/15/2019 7:44 AM*

 

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
> SELINUX=disabled
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

 

Setup SIOS Protection Suite -- Witness Nodes
--------------------------------------------

> \#mount /sapmedia/SIOS931/sps.img /DVD -t iso9660 -o loop
>
> ![][1]
>
> ![][2]
>
> ![][3]

Setup SIOS Protection Suite - SAP Recovery Kit 
-----------------------------------------------

> Install SAP Recovery kit in ASCS and HANA Nodes
>
> \#./setup
>
> ![Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS IS Red Hat Enter r 1 se Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication Install License Key File(s) Recovery Kit Selection Menu •:select:• Done Help Linux Server 7.4 Save \< Load \> ]*Select Install License Key*
>
>  ![A screenshot of a cell phone Description automatically generated]*Enter the license path & click ok*
>
>  ![Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS is Red Hat Enterprise Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication ) Install License Ke File(s) Recover Kit Selection Menu LifeKeeper Startup After Install •:select:• Done Help Linux Server 7.4 Save \< Load \> ]*Select Recovery kit Selection Menu*

 

> ![Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Kit Selection Menu --- Recover Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or A empty submenus llcatlon suite Recovery kit selection. Highlighted letters are hotkeys . pressing Installs features , Removes features . Network/Commun1cat10n Database service Miscellaneous service Mail service Storage support WEB service •:select:• Done Help Save \< Load \> ]*Select Application Suite*

\* *

 

 

 

> ![Machine generated alternative text: SIOS Protection Sulte tor Linux g. 3.1-6750 setup Recover Kit Selection Menu -A lication suite Arrow keys navigate the menu. \<Enter\> selects submenus \--\> to exit, for Help, for Search. u (or empty \] LifeKee Application suite kits list submenus Highlighted letters are hotkeys . pressing Installs features , Removes features . er Webs here MQ/MQSer1es Recover \] LifeKeeper SAP Recovery Kit •:select:• Done Help Kit Save \< Load \> ] *Select Lifekeeper SAP Recovery kit*

 

 

> ![Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS is Red Hat Enterprise Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication ) Install License Key File(s) Recover Kit Selection Menu LifeKee er Startu After Install Done Help Linux Server 7.4 Save \< Load \> ] *Select Lifekeeper Startup after install & Select Done*

 

 

 

 

> ![Machine generated alternative text: SIOS protection Suite for Linux 9.3.1-6750 setup Would you like to start installing SPS for Linux with the current settings? Start the installation. Yes setup will abort. Cancel return to configuration . \< No \> Cancel \> ]*Select Yes & Press Enter* 

 

 

> ![Machine generated alternative text: 310S protection Suite for Linux setup :ollecting system information . \'reparlng configuration information . \'erforming package installation and updating \[nstaII LifeKeeper and dependent packages -I . done . . done . configuration information for SPS for Linux. ]
>
> *Installation completed*
>
>  ![Machine generated alternative text: SIOS protection Suite for Linux setup Collecting system information . preparing configuration information . .done . .done . performing package installation and updating configuration information for SPS for Linux. Install LifeKeeper and dependent packages done . Configure LifeKeeper management group Install licenses. Starting LifeKeeper. . Broadcast message from systemd-journaId\@azrhs4p31 (Fri 2€19-€2-15 PST) : Icdinit\[14303\]: EÆRG:Icd.IcdchksemI: • LifeKeeper product on this system is using an evaluation license key which will expire at midnight on €3/€3/19. me, a permanent license key must be obtained . Message from sysIogd\@azrhs4p31 at Feb 15 €8: 38: 53 Icdinit\[14303\] • LifeKeeper product on this system is using an evaluation license key which will expire at midnight on €3/€3/19. me, a permanent license key must be obtained . Important notice For large configurations, may need to change some settings . please check the Technical Documentation-\>lns tallation and Configuration . Setup complete. \[root\@azrhs4p31 To continue functioning beyond that ti To continue functioning beyond that ti ] *license check message*

Setup SIOS Protection Suite - SAP HANA V2 Recovery Kit
------------------------------------------------------

> \# ls -ltr \|grep HANA2\*
>
> -rwxr\--r\-- 1 root root 24236 Feb 15 08:54 HANA2-ARK.run

Run HANA2-ARK.run
-----------------

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

verify
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
> ![Machine generated alternative text: total 52 - rwxr-xr-x - rwxr-xr-x - rwxr-xr-x - rwxr-xr-x root root root root root root root root 9084 9502 12178 13151 Aug Aug Aug Sep 16 16 16 2017 2017 2017 2017 remove . pl quickcheck . pl recover.pl restore. pl ]

Select lkGUIapp Node
--------------------

> As per the current architecture the most expected/anticipated node to be available is azsuascs2, hence choosing it to perform the SIOS cluster configurations.

a.  Login to azsuascs1 as root

> And start lkGUIapp
>
> \#[]{#_Toc2191416 .anchor}/opt/LifeKeeper/bin/lkGUIapp
>
> Create communication path
>
> ![A picture containing screenshot Description automatically generated]

 

> click comm path icon to create communication path between all the systems in both directions. The output will look like the below screenshot
>
> ![A close up of a logo Description automatically generated]
>
> Note:
>
> Please uncheck the comm path redendency warning in the view menu to see all nodes in green

 

 

8.  SAP HANA System Replication Configuration
    =========================================

    1.  Take Backup of both SYSTEMDB and Tenant DB
        ------------------------------------------

    2.  Copy keys from primary to secondary HANA nodes
        ----------------------------------------------

> SSFS\_S4D.KEY & SSFS\_S4D.DAT from the following paths respectively
>
> /hana/shared/S4D/global/security/rsecssfs/key
>
> /hana/shared/S4D/global/security/rsecssfs/data

Enable HANA System Replication in Primary
-----------------------------------------

> \#*hdbnsutil -sr\_state*
>
> ![Machine generated alternative text: s4dadm\@azsuhana1 : \'us r/sap/S4D/home\> hdbnsutil System Replication State online: true mode : none done . -sr state ]
>
> *Current HSR state*

 

> \# hdbnsutil -sr\_enable --name=left
>
>  ![Machine generated alternative text: r/sap/S4D/home\> hdbnsutil -sr nameserver IS active, proceeding successfully enabled system as system replication done . enable sou -name---left site ]
>
> *Enable system replication on primary node*

 

 

> ![Machine generated alternative text: r/sap/S4D/home\> hdbnsutil -sr nameserver IS active, proceeding successfully enabled system as system replication done . s4dadm\@azsuhana1 : Jus r/sap/S4D/home\> hdbnsutil -sr System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true IS secondary/consumer system: false has secondaries/consumers attached : false IS a takeover active: false enable -name---left source s Ite state Host Mappings : Site Mappings : left (primary/) Tier of left: 1 Replication mode of left: Operation mode of left: done . p r Ima ry ]*Primary HANA System Replication Enabled*

 

Stop HANA in secondary node before registering
----------------------------------------------

>  \#hdbnsutil -sr\_register \--remoteName=left \--remoteHost=azsuhana1 \--remoteInstance=00 \--repliccationMode=syncmem \--operationMode=logreplay \--name=right
>
> ![Machine generated alternative text: s 4dadm\@azsuhana2 : Jus r/sap/S4D/home\> bnsutll adding site responding . nameserver not collecting information updating local ini files done. s 4dadm\@azsuhana2 : Jus r/s ap/S4D/home\> -sr register - remoteName= t - - remoteHost=azsuhana1 - remotelnstance=€€ - replicationMode=s yncmem - -ope rationMode=Iog replay - -name---right ]*Register Secondary node to primary node*
>
> *Note: make sure the ini file gets updated*

*Check HANA System Replication Status*
--------------------------------------

>  \#hdbnsutil -sr\_state
>
> ![Machine generated alternative text: adm\@azsuhanal : \'us r/s ap/S4D/home\> System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true IS secondary/consumer system: false dbnsutll -sr state has secondaries/consumers attached: true IS a takeover active: false Host Mappings : azsuhanal -\> \[right\] azsuhana2 azsuhanal -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/logreplay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem Operation mode of left: primary Operation mode of right: logreplay Mapping: left -\> right done. s 4dadm\@azsuhana1 : Jus r/s ap/S4D/home\> ]
>
> *Check the HSR state*

 

 

> ![Machine generated alternative text: SYSTEMDB\@S4D SYSTEMDB\@S4D (SYSTEM) S4D Version: 2DOB3DO.1S35711040 (fa,\'hana2sp03) Processes Diagnosis Files Emergency Information azsuhana2.provingground.net DO Active Host azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 Process hdbcompileserver hdbdaemon hdbdiserver hdbdiserver hdbindexserver hdbnameserver hdbpreprocessor hdbwebdispatcher hdbxscontroller hdbxsengine hdbxsexecagent hdbxsuaaserver Description HD8 Compileserver HD8 Daemon HD8 Deployment Infrastructure Server HD8 Deployment Infrastructure Server-SAD HD8 Indexserver-S4D HD8 Nameserver HD8 Preprocessor HD8 Web Dispatcher XS Controller HD8 XSEngine-S4D HD8 XS Execution Agent XS UAA server Process ID 87345 87118 87347 87330 87120 87352 87354 Status Running Running Running Running Running Running Running Running Running Running Running Running Start Time Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Elapsed Time 00057 00048 ]*Secondary System Starts after initial Sync*

 

 

> ![Machine generated alternative text: SYSTEMDB\@S4D SYSTEMDB\@S4D SYSTEMDB\@S4D (SYSTEM) S4D azsuhanal.provingground.netD0 Niew Landscape Alerts Performance Volumes Configuration System Information Diagnosis Files Services Hosts Redistribution System Replication Visible rows: 3/3 Trace Configuration REPLICATION STATUS DETAILS Last Update: Feb21, 2019 AM\'S Interval: Filters\... v REPLICATION MODE SYNCMEM SYNCMEM SYNCMEM REPLICATION STATUS ACTIVE INITIALIZING ACTIVE PORT 30007 30,003 30001 12 VOLUME ID SITE ID SITE NAME azsuhana• azsuhana• azsuhana• SECONDARY HOST azsuhana2 azsuhana2 azsuhana2 left left SECONDARY PORT 30007 30,003 30001 SECONDARY SITE ID Full Replica: 12 % (9888/76352 MB) Seconds Save as File SECONDARY SIT right right right ]*Replication Status in HANA Studio*

 

> ![Machine generated alternative text: s4dadm\@azsuhana1 : \'us r/sap/S4D/home\> hdbnsutil System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true is secondary/consumer system: false has secondaries/consumers attached: true IS a takeover active: false Host Mappings : azsuhanal -\> \[right\] azsuhana2 azsuhanal -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/logreplay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem Operation mode of left: primary Operation mode of right: logreplay Mapping: left -\> right done. s 4dadm\@azsuhana1 : \'us r/s ap/S4D/home\> -sr state ]
>
> *HSR status from Primary node*

 

> ![Machine generated alternative text: 4dadm\@azsuhana2 : Jus r/sap/S4D/home\> System Replication State online: true mode: syncmem operation mode: log replay site id: 2 site name: right IS source system: false IS secondary/consumer system: true has secondaries/consumers attached: IS a takeover active: false active primary site: 1 primary masters: azsuhanal Host Mappings : azsuhana2 -\> \[right\] azsuhana2 azsuhana2 -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/log replay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem hdbnsutl L false -sr state Operation mode Operation mode Mapping: left done . of left: primary of right: log replay right ]
>
> *HSR status from secondary node*

9.  SAP HANA Database Protection Configuration
    ==========================================

    6.  Create Virtual IP for HANA DB
        -----------------------------

 

 

 

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ]*Select Generic Application*

 

 

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ]*Select Intelligent, can be changed later*

 

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ]*provide the path of restore script example: /opt/LifeKeeper/ip\_genapp/restore*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]*provide the path for remove script, example: /opt/LifeKeeper/ip\_genapp/remove*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]*provide the path for qucikCheck script, example : /opt/LifeKeeper/ip\_genapp/quickCheck*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]

 

*Screen clipping taken: 2/21/2019 11:57 AM*

 

SIOS-SUSE NIC\_APP-azsuhana1 11.1.2.51 NIC\_APP-azsuhana2 11.1.2.52 11.1.2.50 eth0 S4DDB

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ]

 

*Screen clipping taken: 2/21/2019 11:57 AM*

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ]*Screen clipping taken: 2/21/2019 11:58 AM*

 

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]*Screen clipping taken: 2/21/2019 2:43 PM*

 

 

 

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/ip\_genapp/restore /opt/LifeKeeper/ip\_genapp/remove ip-11.1.2.50 SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC APP-azsuhana2 11.1.2.52 11.1.2.50 etho S4DDB intelligent /opt/LifeKeeper/ip\_genapp/quickCheck /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ]*Screen clipping taken: 2/21/2019 2:44 PM*

 

 

\* *

> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal In e lgen op e eeper Ip\_genapp quic /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes INFORMATION: END successful restore of ip-11.1.2.50 on azsuhanal END successful restore of \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" restored END successful create of \"ip-11.1.2.50\" Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ]*Screen clipping taken: 2/21/2019 2:45 PM*

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suhana2 You have successfully created the resource hierarchy ip-11.1.2.50 on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.50 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ]*Screen clipping taken: 2/21/2019 2:45 PM*

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ]*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ]*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ]*Screen clipping taken: 2/21/2019 2:46 PM*

 

 

> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.50 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Resource Tag Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ]*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Application Info \[optional\] SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC Enter any optional data for ip-11.1.2.50 that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Accept Defaults Cancel ]*Screen clipping taken: 2/21/2019 2:47 PM*

 

 

> ![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch -11.1.2.50 to server azsuhana2 Extending resource instances for ip-11.1.2.50 BEGIN extend of \'lip-11.1.2.50\" END successful extend of \"ip-11.1.2.50\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (ip-11.1.2.50) Released Hierarchy successfully extended \<Back Accept Defaults ]*Screen clipping taken: 2/21/2019 2:48 PM*

 

 

> ![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ]*Screen clipping taken: 2/21/2019 2:48 PM*

 

 

> ![Machine generated alternative text: HANA-S e ip-ll.l. In Service\... Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy\... properties\... ]
>
> *Screen clipping taken: 2/21/2019 2:49 PM*

 

 

Create HANA Resource HANA-S4D
-----------------------------

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][4]*Select Generic Application*
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][5]*Select intelligent*
>
> /opt/LifeKeeper/HANA2-ARK/restore.pl
>
> /opt/LifeKeeper/HANA2-ARK/remove.pl
>
> /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
>
> /opt/LifeKeeper/HANA2-ARK/recover.pl
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/HANA2-ARKJrecover.pl Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that Cancel NeKt\> ]*for the next 4 screens please provide the following path for the scripts*
>
> /opt/LifeKeeper/HANA2-ARK/restore.pl
>
> /opt/LifeKeeper/HANA2-ARK/remove.pl
>
> /opt/LifeKeeper/HANA2-ARK/quickCheck.pl
>
> /opt/LifeKeeper/HANA2-ARK/recover.pl
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] S4D 00 syncrnem left loqreplay Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Cancel ]*Enter Application info as S4D 00 syncmem left logreplay*
>
> Which is \<SID\> \<Instance\#\> \<replicationMode\> \<name\> \<operantionMode\>
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ][6]*Select Yes to bring up the service right away*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 HANA-S40 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]*Provide a Resource tag name*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/HANA2-ARKJrestore.pl /opt/LifeKeeper/HANA2-ARKJremove.pl HANA-S4D S4D 00 syncrnem left logreplay intelligent /opt/LifeKeeper/HANA2-ARKJquickCheck.pl /opt/LifeKeeper/HANA2-ARKJrecover.pl Yes BEGIN create of \"HANA-S40\" creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ]*Hierarchy creation in progress*
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal crea eo creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal The node azsuhanal is already PRIMARY Master HANA-DB S4D 00 is already running on node azsuhanal Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhanal Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" resource \"HANA-S4D\" restored END successful create of \"HANA-S4D\" Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ]*Hierarchy created*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy HANA-S4D on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending HANA-S4D to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ]*Click next to pre extend check to extend the resource hierarchy to secondary node*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ][7]*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ][8]*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ][9]*Click next*
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for HANA-S4D Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]*Pre extend check completed successfully*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Resource Tag HANA-S40 Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ]*Provide resource tag name*
>
> ![Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Application Info \[optional\] S4D 00 syncrnem right loqreplay Enter any optional data for HANA-SO that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Accept Defaults Cancel ]*Provide the Application info as explained in the previous screens*
>
> ![Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch HANA-S4D to server azsuhana2 Extending resource instances for HANA-S4D BEGIN extend of \"HANA-S40\" END successful extend of \"HANA-S4D\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (HANA-S4D) Released Hierarchy successfully extended \<Back Accept Defaults ]*Click finish*
>
> ![Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ][10]
>
> *Click Done*

Create Dependency HANA DB Resource & Azure IP
---------------------------------------------

> Add IP-11.1.2.50 as dependent to HANA-S4D
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ]*Screen clipping taken: 2/21/2019 2:49 PM*

 

 

 

> ![Machine generated alternative text: Create Dependency\@azsuascs2 The following dependency will be created: Parent: HANA-S40 child: ip-11.1.2.50 \<Back Cancel ]
>
> *Click Create Dependency*

 

 

> ![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent HANA-S40 of childi -11.1.2.50 Creating the dependency on the server azsuhanal Creating the dependency on the server azsuhana2 The dependency creation was successful Done ]*Click Done*

 

> ![A screenshot of a cell phone Description automatically generated][11]*Screen clipping to show the dependency tree created*

 

Install SAP Components
======================

> Please follow SAP installation procedure with the recommended settings mentioned in each type of installation

Install SAP (A) System Central Server on Node1 
-----------------------------------------------

> Add virtual hostname and IP address in /etc/host file
>
> 11.1.2.60 s4dascs
>
> \#./sapinst SAPINST\_USE\_HOSTNAME=s4dascs

Install SAP Enqueue Replication Server on Node 1
------------------------------------------------

> \#./sapinst SAPINST\_USE\_HOSTNAME=s4ders (not protected/ no failover)

Install Primary Application Server
----------------------------------

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

Install Addition Application Server (optional)
----------------------------------------------

11. SAP ASCS/ERS cluster configuration
    ==================================

    13. Create floating IP for ASCS
        ---------------------------

> In this step we are creating Enhanced Azure GenApp resource which will create the secondary ip address on the node using azure cli which we installed in earlier step.
>
> The cli command used will be as follows
>
> az network nic ip-config create \--resource-group SIOS-SUSE \--nic-name NIC\_APP-azsuascs1 \--private-ip-address 11.1.2.60 \--name S4DASCS
>
> remove virtual hostname and IP address in /etc/host file 11.1.2.60 s4dascs
>
> ![Machine generated alternative text: Eile Edit Yiew Help ]
>
> Click + icon to create resource hierarchy
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][12]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][13]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ][14]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ][15]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ][16]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ][17]
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
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 SIOS-SUSE NIC APP-azsuascsl 11.1.2.61 NIC Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ][18]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuascsl. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]
>
> ![Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.60 on azsuascsl op e eeper Ip\_genapp recover es BEGIN create of \'lip-11.1.2.60\" creating resource \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" successfully created restoring resource \"ip-11.1.2.60\" BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascsl Note: This process could take up to 2 minutes RTNETLINK answers: File exists INFORMATION: END successful restore of ip-11.1.2.60 on azsuascsl END successful restore of \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" restored END successful create of \"ip-11.1.2.60\" Messages produced while creating ip-11.1.2.60 will be displayed in this dialog and the output panel (if open), and logged on azsuascsl. NeKt\> ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy ip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.60 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ][19]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ][20]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ][21]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]
>
> Don\'t extend now Click close
>
> In Azure the ip will look as shown below
>
> ![A screenshot of a social media post Description automatically generated][22]
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

Create IP Resource Kit
----------------------

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][23]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][24]
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource 11.1.2.60 Enter the IP address or symbolic name to be switched by LifeKeeper. This is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. Cancel NeKt\> ]
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Netmask 255.255.255.0 Enter or select a network mask for the IP resource. Any standard network mask for the class of the specified IP resource address is valid (IPv4 or IPv6 style addresses). Note: The choice of netmask, combined with the address, determines the subnet to be used by the IP resource and should be consistent with the network configuration. \<Back Cancel ]
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Network Interface etho Enter or select the network interface that will be used for the IP resource being placed under LifeKeeper protection. The network interface must support the class of the IP address being protected (IPv4 or IPv6 style addresses). The default value is the first valid network interface that LifeKeeper finds on the target server that supports the class of the address being protected. Valid choices will depend on the existing network configuration and the values chosen for the IP resource address and netmask. \<Back Cancel ]
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource Tag Enter a unique name that will be used to identify this IP resource instance on azsuascsl. The default tag includes the protected IP address. The valid characters allowed for the tag are letters, digits, and the following special characters: \<Back Cancel Create ]
>
> ![Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Creatin cornm/i resource\... BEGIN create of \"vip-11.1.2.60\" LifeKeeper application---comm on azsuascsl. LifeKeeper communications resource type= ip on azsuascsl. Creating resource instance with id IR-11.1.2.60 on machine azsuascsl Resource successfully created on azsuascsl BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" END successful create of \"vip-11.1.2.60\". NeKt\> ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy vip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending vip-11.1.2.60 to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ][25]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ][26]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ][27]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for vip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]
>
> Don\'t extend now, click close
>
> Create dependency
>
> Add ip-11.1.2.60 as dependency to vip-11.1.2.60
>
> ![Machine generated alternative text: e HAN Out of Service\... e Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... ]
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ][28]
>
> ![Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent vi -11.1.2.60 of child i -11.1.2.60 Creating the dependency on the server azsuascsl The dependency creation was successful Done ]

Create Data Replication Resource for ASCS mount
-----------------------------------------------

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][29]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][30]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ][31]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Hierarchy Type Choose the type of data replication hierarchy you wish to create: Replicate New Filesystem creates a new replicated filesystem and makes it accessible on a given mount point. Replicate Existing Filesystem converts an already mounted filesystem into a replicated filesystem. Data Replication Resource creates just a data replication device, with no associated filesystem. The filesystem (or raw disk access) must be configured manually. Cancel NeKt\> ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 ATTENTION! /mnt/resource is not shareable with any other server. using this choice will result in a data replication hierarchy that cannot be extended to other servers to form a shared-storage configuration. To confirm the selection of this entry press Continue. Press Back to select a different entry from the list. \<Back Cancel ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Existing Mount Point Select the desired mount point to be replicated. The mount point must already be mounted. \<Back Cancel NeKt\> ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 datarep-Ascsoo Data Replication Resource Tag Enter or select a unique tag name for the data replication resource instance. \<Back Cancel ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 File System Resource Tag usr/sap/S4D/Ascsoo Enter or select a unique tag name for the filesystem resource instance. \<Back Cancel ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Bitmap File /LifeKeeper/bitmap usr sap\_S4D ASCSOO The bitmap file keeps a log of all changed sectors on the disk that have not yet been committed to the target(s). It is useful in the event of a network outage or system downtime because only the changed sectors need to be sent. By default, the bitmap file will contain one bit per 256KB of data on the disk (this can be changed with the LKDR CHUNK SIZE variable). Without a bitmap file, any interruption of the replication process will require a full resynchronization of all mirror targets. \<Back Cancel ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Enable Asynchronous Replication ? no Select whether you want to enable asynchronous replication for this mirror. This is a global option for the entire mirror. Individual targets may be either synchronous or asynchronous. You must select yes if you plan to have any asynchronous targets in this mirror. You should select no if you plan to have on/y synchronous targets. Asynchronous means that writes are signalled as committed when they are safely on the source, but may still be in flight to one or more targets. Asynchronous replication requires a bitmap file. Asynchronous replication is mainly employed in WAN environments. Synchronous means that writes are only signalled as committed when they are safely on the source and all targets. With a synchronous mirror, committed transactions will not be lost even in the event of a server failure. Synchronous mirrors are mainly employed in LAN environments, where the network is fast enough to keep up with the normal write load on the protected filesystem. \<Back Cancel ]
>
> ![Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Creatin Data Re lication Resource\... mount -t Hfs -o /dev/md0 /usr/sap/S4D/Ascsoo devicehier: using /opt/LifeKeeper/lkadm/subsys/scsi/netraid/bin/devicehier to construct the hierarchy WARNING. WARNING: WARNING: WARNING: WARNING. WARNING: WARNING: WARNING: The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. NeKt\> ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suasc You have successfully created the resource hierarchy datarep-ASCS00 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending datarep-ASCS00 to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ][32]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ][33]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ][34]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for datarep-ASCS00 Checking extendability for /usr/sap/S4D/ASCS00 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]
>
> Click close and don\'t click next to extent the resource to the target side yet. The screen will be as shown below.

Create SAP Resource SAP-S4D\_ASCS00
-----------------------------------

> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][35]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][36]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ][37]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ASCSOO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 IP child resource Select the IP Address for this instance, this is typically the virtual IP address used during installation as specified by the SAPINST LJSE HOSTNAME parameter. \<Back Cancel NeKt\> ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ASCSOO Enter the Tag name for this instance. I ate I \<Back Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource.. 26.02.2019 StartWait The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function StartWait 22B 5\" command returned \"SUCCESS\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" on \"azsuascsl Please wait.. The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ASCSOO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The the and END END SAP Instance \"ASCSOO\" and all required processes were started successfully during \"restore\" on server \"azsuascsl Additional information is available in the LifeKeeper system logs. successful restore of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" successful create of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" NeKt\> ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy SAP-S4D ASCSOO on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending SAP-S4D ASCSOO to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ][38]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ][39]
>
> ![Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ][40]
>
> Click close here and don't go further
>
> ![Machine generated alternative text: Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ]

Create SAP Resource SAP-S4D\_ERS10
----------------------------------

> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsu Disconnect\... Refresh.. View Logs\... Create Resource Hierarchy\... Create Comm Path\... Delete Comm Path\... properties\... azsuascs2 ]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ][41]
>
> ![Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ][42]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ][43]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ERSIO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 AP-S4D ASCSOO Select dependent instances Select the Dependent Central Instance for this application instance, ERSIO. This will create a dependency. \<Back NeKt\> Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ERSIO Enter the Tag name for this instance. I ate I \<Back Cancel ]
>
> ![Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource\... Preparing to run the command: \"/usr/sap/hostctrl/exe/saphostexec -status\" on \"azsuascsl Please wait\... start hostcontrol using profile /usr/sap/hostctrl/exe/host\_profile saphostexec running (pid = 3130) sapstartsrv running (pid = 3315) saposcol running (pid = 3379) The command \"/usr/sap/hostctrl/exe/saphostexec\" is running on \"azsuascsl Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascsl Please wait\... Warning the profile file /usr/sap/S4D/ERS10/profile/S4D ERSIO s4ders for SID S4D and Instance ERSIO has Autostart is enabled on azsuascsl. Disable Autostart for the specified instance by setting Autostart=0 in the profile file There are no equivalent systems available to perform the \"isSAPRKSRunning\" action for the Replicate Enqueue Instance \"ERSIO\" on \"azsuascsl The resource must be extended to at most one server before this operation can complete END successful restore of \"SAP-S4D ERSIO\" on server \"azsuascsl \" END successful create of \"SAP-S4D ERSIO\" on server \"azsuascsl \" NeKt\> ]
>
> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e vip-11.1.2.60 e /usr/sap/S4D/Ascsoo HANA-S40 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ]
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Target Disk Select a disk on azsuascs2. The selection must not be mounted and must be at least as large as the source disk on azsuascsl. Accept Defaults Cancel NeKt\> ]
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Data Replication Resource Tag datarep-Ascsoo Enter or select a unique tag name for the data replication \<Back Accept Defaults Cancel resource instance. ]
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Data Replication Resource Tag datarep-Ascsoo Enter or select a unique tag name for the data replication \<Back Accept Defaults Cancel resource instance. ]
>
> ![Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Replication Path Select the network end points to be used for replication between systems azsuascsl and azsuascs2. \<Back NeKt\> Accept Defaults Cancel ]
>
> ![Machine generated alternative text: Extend comm/ip Resource Hierarchy\@azsuascs2 Template Server: azsuascsl Tag to Extend: vip-11.1.2.60 Target Server: azsuascs2 IP Resource The IP address or symbolic name to be protected by the IP resource on the target server. The same value that was used on the template server is used for the IP resource on the target server. Therefore, this value cannot be changed. The IP resource is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. NeKt\> Accept Defaults Cancel ]
>
> Click accept defaults
>
> ![Machine generated alternative text: Eile Edit Yiew Help Hierarchies Not Active datarep-Ascsoo SAP-S4D ASCSOO SAP-S4D ERSIO vip-11.1.2.60 SAP-S4D ERSIO azsusapwitl azsusapwit2 azsuascsl azsuascs2 azsuhanal azsuhana2 ]
>
> ![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 azsusapwitl azsusapwit2 Extend Wizard\@azsuascs2 azsuascsl azsuascs2 azsuhanal azsuhana2 Extendin resource hierarch -11.1.2.60 to server azsuascs2 Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/create\_ins\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/depstoeHtend\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/genftilesys/bin/eHtend\" on \"azsuascs2\". Please wait\... BEGIN extend of \'lip-11.1.2.60\" END successful extend of \"ip-11.1.2.60\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (SAP-S4D ERSIO) Released Hierarchy successfully extended Next Server Accept Defaults ]
>
> Click finish and Done in the next screen

12. SIOS Failover Testing
    =====================

    18. SAP HANA Database Failover
        --------------------------

> ![Machine generated alternative text: Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S In Service.. e ip-l Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ]

 

*Screen clipping taken: 2/20/2019 8:44 PM*

 

 

> ![Machine generated alternative text: InService\@azsuascs2 NeKt\> Cancel ]

 

*Screen clipping taken: 2/20/2019 8:45 PM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 Confirm in service action for Server: azsuhana2 Resource: HANA-S40 azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 \<Back Cancel ]

 

*Screen clipping taken: 2/20/2019 8:46 PM*

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service Done azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ]

 

*Screen clipping taken: 2/20/2019 8:47 PM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--private-ip-address 11.1.2.50 azsuhanal azsuhana2 e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhana2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.50 on azsuhana2 END successful restore of \"ip-11.1.2.50\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Done \--nic-name NIC APP-azsuhana2 \--name ipconfig2 \> /dev/null 2\>&1) on azsuhanal ]

 

*Screen clipping taken: 2/20/2019 8:50 PM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 Brin in HANA-S4D in service on azsuhana2 SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Node azsuhana2 is now PRIMARY master Takeover of System Replication finished successful on node azsuhana2 HANA-DB S4D 00 is already running on node azsuhana2 DEBUG\[0524\]: getRemoteHostParmName: set profileHostName=azsuhana2. dflt=azsuhana2 Replication mode on node azsuhanal is now syncrnem Reenable system replication on node azsuhanal finished successful Node azsuhanal is now registered in system replication mode syncrnem at node azsuhana2 SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Starting HANA-DB S4D 00 on node azsuhanal Start of HANA-DB S4D 00 on node azsuhanal successful Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhana2 Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" Put \"HANA-S4D\" in-service successful Done ]

 

*Screen clipping taken: 2/20/2019 8:52 PM*

 

 

 

 

 

SAP ASCS Failover
-----------------

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D SAP-S e e HANA-S4 update Protection Level update Recoveru Level Handle Warnings SSCC HA Actions In Service\... Out of Service\... Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy.. properties\... ]

 

*Screen clipping taken: 2/21/2019 11:48 AM*

 

 

 

 

![Machine generated alternative text: InService\@azsuascs2 NeKt\> Cancel ][44]

 

*Screen clipping taken: 2/21/2019 11:48 AM*

 

 

![Machine generated alternative text: n Service\@azsuascs2 Confirm in service action for Server: azsuascs2 Resource: SAP-S4D ERSIO (SAPID-S40-ERSIO) \<Back Cancel ]

 

*Screen clipping taken: 2/21/2019 11:48 AM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS Done ]

 

*Screen clipping taken: 2/21/2019 11:49 AM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Done ]

 

*Screen clipping taken: 2/21/2019 11:50 AM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--name S4DASCS \> /dev/null 2\>&1) on azsuascsl azsuhanal azsuhana2 e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.60 on azsuascs2 END successful restore of \"ip-11.1.2.60\" BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" Done \--nic-name NIC APP-azsuersl \--private-ip-address 11.1.2.60 ]

 

*Screen clipping taken: 2/21/2019 11:51 AM*

 

 

![Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo Target azsusapwitl n Service\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 saposcol running (pid = 1979) azsusapwit2 azsuascsl azsuascs2 azsuhanal azsuhana2 e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 The command \"/usr/sap/hostctrl/exe/saphostexec\" is running on \"azsuascsl Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascsl Please wait.. Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host azsuascsl -nr 10 -function GetProcessList\" on \"azsuascsl Please wait\... The \"sapcontrol -format script -prot NI HI-rp -host azsuascsl -nr 10 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ERSIO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The \"SAPInstanceCmd\" command returned \"1 \" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/remoteControl SAP-S4D ERSIO ERSIO \"SAPInstanceCmd\" \"start\" \"azsuascsl \" \"SAP-S4D ERSIO\" command returned \"1 \" on \"azsuascs2\". Additional information is available in the LifeKeeper and system logs The SAP Instance \"ERSIO\" and all required processes were started successfully during the \"restore\" on server \"azsuascs2\". Additional information is available in the LifeKeeper and system logs. END successful restore of \"SAP-S4D ERSIO\" on server \"azsuascs2\" Put \"SAP-S4D ERSIO\" in-service successful Done ]*Screen clipping taken: 2/21/2019 11:52 AM*

 

 

Lesson's learned
================

  [cid:image001.png\@01D3CB5A.56717E50]: media/image1.png {width="1.1979166666666667in" height="0.46875in"}
  [1. Introduction 4]: #introduction
  [2. Reference Architecture 4]: #reference-architecture
  [2.1 Virtual IP & Hostnames 5]: #virtual-ip-hostnames
  [2.2 Witness or Quorum Hosts 5]: #witness-or-quorum-hosts
  [2.3 Disk layout for ASCS Cluster Nodes 5]: #disk-layout-for-ascs-cluster-nodes
  [2.4 Firewall 5]: #firewall
  [2.5 Reference Architecture Diagram 5]: #reference-architecture-diagram
  [3. SAP HA Scenario 6]: #infrastructure-provisioning
  [4. Azure CLI Installation for Linux 7]: #azure-cli-installation-for-linux
  [4.1 SuSE 7]: #suse
  [4.1.1 Install curl: 7]: #install-curl
  [4.1.2 Import the Microsoft repository key: 7]: #import-the-microsoft-repository-key
  [4.2 RHEL 7]: #rhel
  [4.2.1 Import the Microsoft repository key. 7]: #import-the-microsoft-repository-key.
  [4.2.2 Create local azure-cli repository information 8]: #create-local-azure-cli-repository-information
  [4.2.3 Install with the yum install command. 8]: #install-with-the-yum-install-command.
  [4.2.4 Run the login command 9]: #run-the-login-command
  [5. SIOS Protection Suite 9.3.1 9]: #sios-protection-suite-9.3.1
  [5.1 Preparation - Only for RHEL 9]: #preparation---only-for-rhel
  [5.2 Setup SIOS Protection Suite -- Witness Nodes 10]: #setup-sios-protection-suite-witness-nodes
  [5.3 Setup SIOS Protection Suite - SAP Recovery Kit 12]: #setup-sios-protection-suite---sap-recovery-kit
  [5.4 Setup SIOS Protection Suite - SAP HANA V2 Recovery Kit 16]: #setup-sios-protection-suite---sap-hana-v2-recovery-kit
  [5.4.1 Run HANA2-ARK.run 16]: #run-hana2-ark.run
  [5.4.2 verify 16]: #verify
  [5.4.3 Select lkGUIapp Node 16]: #select-lkguiapp-node
  [5.4.4 Create communication path 16]: #_Toc2191416
  [8. SAP HANA System Replication Configuration 16]: #sap-hana-system-replication-configuration
  [9. SAP HANA Database Protection Configuration 16]: #sap-hana-database-protection-configuration
  [9.1 Create Virtual IP for HANA DB 16]: #create-virtual-ip-for-hana-db
  [9.2 Create HANA Resource HANA-S4D 17]: #create-hana-resource-hana-s4d
  [9.3 Create Dependency HANA DB Resource & Azure IP 27]: #create-dependency-hana-db-resource-azure-ip
  [10. Install SAP Components 29]: #install-sap-components
  [10.1 Install SAP (A) System Central Server 29]: #install-sap-a-system-central-server-on-node1
  [10.2 Install SAP Enqueue Replication Server 29]: #install-sap-enqueue-replication-server-on-node-1
  [10.3 Install Primary Application Server 29]: #install-primary-application-server
  [10.4 Install Addition Application Server (optional) 30]: #install-addition-application-server-optional
  [11. SAP ASCS/ERS cluster configuration 30]: #sap-ascsers-cluster-configuration
  [11.1 Create floating IP for ASCS 30]: #create-floating-ip-for-ascs
  [11.2 Create IP Resource Kit 40]: #create-ip-resource-kit
  [11.3 Create Data Replication Resource for ASCS mount 40]: #create-data-replication-resource-for-ascs-mount
  [11.4 Create SAP Resource SAP-S4D\_ASCS00 40]: #create-sap-resource-sap-s4d_ascs00
  [11.5 Create SAP Resource SAP-S4D\_ERS10 40]: #create-sap-resource-sap-s4d_ers10
  [12. SIOS Failover Testing 40]: #sios-failover-testing
  [12.1 SAP HANA Database Failover 40]: #sap-hana-database-failover
  [12.2 SAP ASCS Failover 40]: #sap-ascs-failover
  [13. Lesson's learned 40]: #lessons-learned
  [A screenshot of a social media post Description automatically generated]: media/image2.tmp {width="4.094320866141732in" height="2.166969597550306in"}
  [azsuhanal:--- \# sudo zypper install -y curl Refreshing service \'SMT-http\_smt-azure\_susecIoud\_net• . Refreshing service •cloud \_ update\' . Retrieving repository \'SLE-Module-pubIic-C10ud12-Updates• metadata Building repository \'SLE-Module-pub1ic-C10ud12-Updates• cache Retrieving repository \'SLE-SDK12-SP3-Updates• metadata Building repository \'SLE-SDK12-SP3-Updates• cache . Retrieving repository \'SLES12-SP3-Updates• metadata Building repository \'SLES12-SP3-Updates• cache Loading repository data. Reading installed packages . . Resolving package dependencies. . The following package is going to be upgraded: curl 1 package to upgrade . Overall download size: 153.4 KiB. Already cached: Continue? \[yin/ . ? shows all options\] (y): Y Retrieving package curl-7.37.0-37.31.1. x86 64 Retrieving: curl-7.37.0-37.31.1.x86 64. rpm Checking for file conflicts : (1/1) Installing: curl-7.37.e-37.31.1.x86 64 azsuhanal:--- \# e B. additional space will be used or f reed after the ope ration . (1/1), . \[done\] . \[done\] . \[done\] . \[done\] . \[done\] . \[done\] 153.4 KiB (312.9 KiB unpacked) . \[done\] . \[done\] . \[done\] ]: media/image4.png {width="6.5in" height="1.601388888888889in"}
  [\*zsuhanal:--- \*zsuhanal:--- sudo rpm - -Import https ://packages.mlcrosott.com/keys/mlcrosott . asc \# sudo zypper add repo -check https://packages.mlcrosoft . com/yumrepos/azure-cli azure-cli -name \'Azure CLI\' Xdding repository \'Azure CLI\' {epository \'Azure CLI\' successfully added https : //packages . mic rosoft . com/yumrepos/azure-cli . \[done\] Enabled 3PG Check W to refresh \'rlority Yes Yes 99 (default priority) {epository priorities are without effect . \*zsuhanal:--- \# All enabled repositories share the same priority. ]: media/image5.png {width="6.5in" height="0.8902777777777777in"}
  [azsuhanal:--- sudo zypper addrepo -name Adding repository \'Azure CLI\' Repository \'Azure CLI\' successfully added \'Azure CLI\' https://packages.mlcrosott . com/yumrepos/azure-cll azure-cL1 Enabled GPG Check Auto ref resh priority https : //packages . mic rosoft . com/yumrepos/azure-cli Yes 99 (default priority) Repository priorities are without effect. All enabled azsuhanal:--- \# sudo zypper install -from azure-cli -y Refreshing service \'SMT-http\_smt-azure\_susecIoud\_net\' . Refreshing service •cloud \_ update\' . Building repository \'Azure CLI\' cache Loading repository data. Reading installed packages. . . Resolving package dependencies . . . The following NEW package is going to be installed: azure-cli The following package has no support information from azure-cli 1 new package to install. Overall download size: 25.1 MiB. Already cached: € B. Continue? \[yin/ . ? shows all options\] (y): Y Retrieving package azure-cli-2.e.53-1.e17. x86 64 Retrieving: azure-cli-2.€.53-1.e17.x86 64. rpm Checking for file conflicts : (1/1) Installing: azure-cli-2.€.53-1.e17. x86 64 azsuhanal:--- \# repositories share the same priority. azure-cli it\'s vendor: After the operation, additional 177 .5 Mie will be used . (1/1), . \[done\] . \[done\] 25.1 Mie (177.5 Mie unpacked) . \[done\] . \[done\] . \[done\] ]: media/image6.png {width="6.5in" height="2.107638888888889in"}
  [Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup pre-lnstall check failed: : SELinux appears to be enabled. please disable SELinux before installing SPS for Linux. ]: media/image7.png {width="6.5in" height="3.589583333333333in"}
  [1]: media/image8.png {width="6.5in" height="3.8854166666666665in"}
  [2]: media/image9.png {width="6.5in" height="3.926388888888889in"}
  [3]: media/image10.png {width="6.5in" height="1.45625in"}
  [Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS IS Red Hat Enter r 1 se Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication Install License Key File(s) Recovery Kit Selection Menu •:select:• Done Help Linux Server 7.4 Save \< Load \> ]: media/image11.png {width="6.5in" height="3.5861111111111112in"}
  [A screenshot of a cell phone Description automatically generated]: media/image12.png {width="6.5in" height="3.6020833333333333in"}
  [Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS is Red Hat Enterprise Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication ) Install License Ke File(s) Recover Kit Selection Menu LifeKeeper Startup After Install •:select:• Done Help Linux Server 7.4 Save \< Load \> ]: media/image13.png {width="6.5in" height="3.602777777777778in"}
  [Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Kit Selection Menu --- Recover Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or A empty submenus llcatlon suite Recovery kit selection. Highlighted letters are hotkeys . pressing Installs features , Removes features . Network/Commun1cat10n Database service Miscellaneous service Mail service Storage support WEB service •:select:• Done Help Save \< Load \> ]: media/image14.png {width="6.5in" height="3.613888888888889in"}
  [Machine generated alternative text: SIOS Protection Sulte tor Linux g. 3.1-6750 setup Recover Kit Selection Menu -A lication suite Arrow keys navigate the menu. \<Enter\> selects submenus \--\> to exit, for Help, for Search. u (or empty \] LifeKee Application suite kits list submenus Highlighted letters are hotkeys . pressing Installs features , Removes features . er Webs here MQ/MQSer1es Recover \] LifeKeeper SAP Recovery Kit •:select:• Done Help Kit Save \< Load \> ]: media/image15.png {width="6.5in" height="3.59375in"}
  [Machine generated alternative text: SIOS protection Suite for Linux g. 3.1-6750 setup Arrow keys navigate the menu. selects submenus to exit, for Help, for Search. (or empty submenus Maln configuration Highlighted letters are hotkeys . pressing Installs features , Removes features . Your OS is Red Hat Enterprise Install Java Runtime (JRE) Use Quorum / Witness Functions LifeKeeper Authentication ) Install License Key File(s) Recover Kit Selection Menu LifeKee er Startu After Install Done Help Linux Server 7.4 Save \< Load \> ]: media/image16.png {width="6.5in" height="3.5944444444444446in"}
  [Machine generated alternative text: SIOS protection Suite for Linux 9.3.1-6750 setup Would you like to start installing SPS for Linux with the current settings? Start the installation. Yes setup will abort. Cancel return to configuration . \< No \> Cancel \> ]: media/image17.png {width="6.5in" height="3.5972222222222223in"}
  [Machine generated alternative text: 310S protection Suite for Linux setup :ollecting system information . \'reparlng configuration information . \'erforming package installation and updating \[nstaII LifeKeeper and dependent packages -I . done . . done . configuration information for SPS for Linux. ]: media/image18.png {width="6.5in" height="1.1958333333333333in"}
  [Machine generated alternative text: SIOS protection Suite for Linux setup Collecting system information . preparing configuration information . .done . .done . performing package installation and updating configuration information for SPS for Linux. Install LifeKeeper and dependent packages done . Configure LifeKeeper management group Install licenses. Starting LifeKeeper. . Broadcast message from systemd-journaId\@azrhs4p31 (Fri 2€19-€2-15 PST) : Icdinit\[14303\]: EÆRG:Icd.IcdchksemI: • LifeKeeper product on this system is using an evaluation license key which will expire at midnight on €3/€3/19. me, a permanent license key must be obtained . Message from sysIogd\@azrhs4p31 at Feb 15 €8: 38: 53 Icdinit\[14303\] • LifeKeeper product on this system is using an evaluation license key which will expire at midnight on €3/€3/19. me, a permanent license key must be obtained . Important notice For large configurations, may need to change some settings . please check the Technical Documentation-\>lns tallation and Configuration . Setup complete. \[root\@azrhs4p31 To continue functioning beyond that ti To continue functioning beyond that ti ]: media/image19.png {width="6.5in" height="1.4076388888888889in"}
  [Machine generated alternative text: total 52 - rwxr-xr-x - rwxr-xr-x - rwxr-xr-x - rwxr-xr-x root root root root root root root root 9084 9502 12178 13151 Aug Aug Aug Sep 16 16 16 2017 2017 2017 2017 remove . pl quickcheck . pl recover.pl restore. pl ]: media/image20.png {width="4.635416666666667in" height="0.78125in"}
  [A picture containing screenshot Description automatically generated]: media/image21.tmp {width="5.75080271216098in" height="0.6146686351706037in"}
  [A close up of a logo Description automatically generated]: media/image22.tmp {width="14.194511154855643in" height="0.6354166666666666in"}
  [Machine generated alternative text: s4dadm\@azsuhana1 : \'us r/sap/S4D/home\> hdbnsutil System Replication State online: true mode : none done . -sr state ]: media/image23.png {width="4.6715277777777775in" height="1.4256944444444444in"}
  [Machine generated alternative text: r/sap/S4D/home\> hdbnsutil -sr nameserver IS active, proceeding successfully enabled system as system replication done . enable sou -name---left site ]: media/image24.png {width="5.813194444444444in" height="0.6340277777777777in"}
  [Machine generated alternative text: r/sap/S4D/home\> hdbnsutil -sr nameserver IS active, proceeding successfully enabled system as system replication done . s4dadm\@azsuhana1 : Jus r/sap/S4D/home\> hdbnsutil -sr System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true IS secondary/consumer system: false has secondaries/consumers attached : false IS a takeover active: false enable -name---left source s Ite state Host Mappings : Site Mappings : left (primary/) Tier of left: 1 Replication mode of left: Operation mode of left: done . p r Ima ry ]: media/image25.png {width="5.918055555555555in" height="5.76875in"}
  [Machine generated alternative text: s 4dadm\@azsuhana2 : Jus r/sap/S4D/home\> bnsutll adding site responding . nameserver not collecting information updating local ini files done. s 4dadm\@azsuhana2 : Jus r/s ap/S4D/home\> -sr register - remoteName= t - - remoteHost=azsuhana1 - remotelnstance=€€ - replicationMode=s yncmem - -ope rationMode=Iog replay - -name---right ]: media/image26.png {width="6.5in" height="0.47291666666666665in"}
  [Machine generated alternative text: adm\@azsuhanal : \'us r/s ap/S4D/home\> System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true IS secondary/consumer system: false dbnsutll -sr state has secondaries/consumers attached: true IS a takeover active: false Host Mappings : azsuhanal -\> \[right\] azsuhana2 azsuhanal -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/logreplay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem Operation mode of left: primary Operation mode of right: logreplay Mapping: left -\> right done. s 4dadm\@azsuhana1 : Jus r/s ap/S4D/home\> ]: media/image27.png {width="4.76875in" height="6.604166666666667in"}
  [Machine generated alternative text: SYSTEMDB\@S4D SYSTEMDB\@S4D (SYSTEM) S4D Version: 2DOB3DO.1S35711040 (fa,\'hana2sp03) Processes Diagnosis Files Emergency Information azsuhana2.provingground.net DO Active Host azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 azsuhana2 Process hdbcompileserver hdbdaemon hdbdiserver hdbdiserver hdbindexserver hdbnameserver hdbpreprocessor hdbwebdispatcher hdbxscontroller hdbxsengine hdbxsexecagent hdbxsuaaserver Description HD8 Compileserver HD8 Daemon HD8 Deployment Infrastructure Server HD8 Deployment Infrastructure Server-SAD HD8 Indexserver-S4D HD8 Nameserver HD8 Preprocessor HD8 Web Dispatcher XS Controller HD8 XSEngine-S4D HD8 XS Execution Agent XS UAA server Process ID 87345 87118 87347 87330 87120 87352 87354 Status Running Running Running Running Running Running Running Running Running Running Running Running Start Time Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Feb 21, 2019 AM Elapsed Time 00057 00048 ]: media/image28.png {width="6.5in" height="3.5444444444444443in"}
  [Machine generated alternative text: SYSTEMDB\@S4D SYSTEMDB\@S4D SYSTEMDB\@S4D (SYSTEM) S4D azsuhanal.provingground.netD0 Niew Landscape Alerts Performance Volumes Configuration System Information Diagnosis Files Services Hosts Redistribution System Replication Visible rows: 3/3 Trace Configuration REPLICATION STATUS DETAILS Last Update: Feb21, 2019 AM\'S Interval: Filters\... v REPLICATION MODE SYNCMEM SYNCMEM SYNCMEM REPLICATION STATUS ACTIVE INITIALIZING ACTIVE PORT 30007 30,003 30001 12 VOLUME ID SITE ID SITE NAME azsuhana• azsuhana• azsuhana• SECONDARY HOST azsuhana2 azsuhana2 azsuhana2 left left SECONDARY PORT 30007 30,003 30001 SECONDARY SITE ID Full Replica: 12 % (9888/76352 MB) Seconds Save as File SECONDARY SIT right right right ]: media/image29.png {width="6.5in" height="1.0680555555555555in"}
  [Machine generated alternative text: s4dadm\@azsuhana1 : \'us r/sap/S4D/home\> hdbnsutil System Replication State online: true mode: primary operation mode: primary site id: 1 site name: left IS source system: true is secondary/consumer system: false has secondaries/consumers attached: true IS a takeover active: false Host Mappings : azsuhanal -\> \[right\] azsuhana2 azsuhanal -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/logreplay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem Operation mode of left: primary Operation mode of right: logreplay Mapping: left -\> right done. s 4dadm\@azsuhana1 : \'us r/s ap/S4D/home\> -sr state ]: media/image30.png {width="4.686805555555556in" height="6.709027777777778in"}
  [Machine generated alternative text: 4dadm\@azsuhana2 : Jus r/sap/S4D/home\> System Replication State online: true mode: syncmem operation mode: log replay site id: 2 site name: right IS source system: false IS secondary/consumer system: true has secondaries/consumers attached: IS a takeover active: false active primary site: 1 primary masters: azsuhanal Host Mappings : azsuhana2 -\> \[right\] azsuhana2 azsuhana2 -\> \[left\] azsuhanal Site Mappings : left (primary/primary) - right (syncmem/log replay) Tier of left: 1 Tier of right: 2 Replication mode of left: primary Replication mode of right: syncmem hdbnsutl L false -sr state Operation mode Operation mode Mapping: left done . of left: primary of right: log replay right ]: media/image31.png {width="4.80625in" height="6.843055555555556in"}
  [Machine generated alternative text: Create Resource Wizard\@azsuascs2 Please Select Recovery Kit NeKt\> Cancel ]: media/image32.png {width="6.28125in" height="4.177083333333333in"}
  [Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back Switchback Type intelligent Cancel ]: media/image33.png {width="6.260416666666667in" height="4.197916666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Restore Script opt/LifeKeeper/ip\_genapp/restore Enter the pathname for the shell script or object program which starts the application. The restore script is responsible for bringing a protected application resource in-service. The restore script should not impact an active resource application when invoked. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that NeKt\> Cancel ]: media/image34.png {width="6.302083333333333in" height="4.166666666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Remove Script opt/LifeKeeper/ip\_genapp/remove Enter the pathname for the shell script or object program which stops the application. The remove script is responsible for stopping a protected application resource and putting it in the out-of-service state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]: media/image35.png {width="6.260416666666667in" height="4.166666666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/quickCheck QuickCheck Script \[optional\] Enter the pathname for the shell script or object program which monitors the application. The quickCheck script is called periodically, and is responsible for performing a health check of the protected application. The quickCheck script is optional. If one is not provided it will always be assumed that the application is in an OK state. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]: media/image36.png {width="6.28125in" height="4.15625in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/ip\_genapp/recover Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that \<Back Cancel ]: media/image37.png {width="6.270833333333333in" height="4.208333333333333in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ]: media/image38.png {width="6.239583333333333in" height="4.197916666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Bring Resource In Service This field allows the user to specify if the resource should be brought in-service following a successful create. • A user may want to select No if the dependent resources have not been created and the restore command would fail. If No is selected, the resource will be created but will not be brought in-service. The resource cannot be extended until the hierarchy has been placed in-service. • Selecting Yes will cause the resource has been created. \<Back Cancel NeKt\> user provided restore script to be invoked after the ]: media/image39.png {width="6.25in" height="4.197916666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]: media/image40.png {width="6.270833333333333in" height="4.177083333333333in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/ip\_genapp/restore /opt/LifeKeeper/ip\_genapp/remove ip-11.1.2.50 SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC APP-azsuhana2 11.1.2.52 11.1.2.50 etho S4DDB intelligent /opt/LifeKeeper/ip\_genapp/quickCheck /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ]: media/image41.png {width="6.270833333333333in" height="4.1875in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.50 on azsuhanal In e lgen op e eeper Ip\_genapp quic /opt/LifeKeeper/ip\_genapp/recover Yes BEGIN create of \'lip-11.1.2.50\" creating resource \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" successfully created restoring resource \"ip-11.1.2.50\" BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhanal Note: This process could take up to 2 minutes INFORMATION: END successful restore of ip-11.1.2.50 on azsuhanal END successful restore of \"ip-11.1.2.50\" resource \"ip-11.1.2.50\" restored END successful create of \"ip-11.1.2.50\" Messages produced while creating ip-11.1.2.50 will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ]: media/image42.png {width="6.260416666666667in" height="4.166666666666667in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suhana2 You have successfully created the resource hierarchy ip-11.1.2.50 on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.50 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ]: media/image43.png {width="6.302083333333333in" height="4.15625in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Switchback Type Accept Defaults intelligent Cancel ]: media/image44.png {width="6.260416666666667in" height="4.197916666666667in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Template Priority Accept Defaults Cancel ]: media/image45.png {width="6.260416666666667in" height="4.21875in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 \<Back Target Priority Accept Defaults Cancel ]: media/image46.png {width="6.28125in" height="4.208333333333333in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.50 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]: media/image47.png {width="6.229166666666667in" height="4.166666666666667in"}
  [Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Resource Tag Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ]: media/image48.png {width="6.291666666666667in" height="4.177083333333333in"}
  [Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: ip-11.1.2.50 Target Server: azsuhana2 Application Info \[optional\] SIOS-SUSE NIC APP-azsuhanal 11.1.2.51 NIC Enter any optional data for ip-11.1.2.50 that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Accept Defaults Cancel ]: media/image49.png {width="6.28125in" height="4.177083333333333in"}
  [Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch -11.1.2.50 to server azsuhana2 Extending resource instances for ip-11.1.2.50 BEGIN extend of \'lip-11.1.2.50\" END successful extend of \"ip-11.1.2.50\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (ip-11.1.2.50) Released Hierarchy successfully extended \<Back Accept Defaults ]: media/image50.png {width="6.260416666666667in" height="4.1875in"}
  [Machine generated alternative text: Hierarchy Integrity Verfication\@azsuascs2 Veri in Inte rit of Extended Hierarch Examining hierarchy on azsuhana2 Hierarchy Verification Finished \<Back ne Accept Defaults ]: media/image51.png {width="6.260416666666667in" height="4.21875in"}
  [Machine generated alternative text: HANA-S e ip-ll.l. In Service\... Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy\... properties\... ]: media/image52.png {width="3.3958333333333335in" height="2.1666666666666665in"}
  [4]: media/image54.png {width="6.260416666666667in" height="4.177083333333333in"}
  [5]: media/image55.png {width="6.25in" height="4.1875in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 opt/LifeKeeper/HANA2-ARKJrecover.pl Local Recovery Script \[optional\] Enter the pathname for the shell script or object program which will attempt to recover a failed application on the local server. This may require stopping and restarting the application. The local recovery script is optional - if you do not want to provide one, simply clear the entry field. If no local recovery script is provided, the protected application will always fail over to the target when a quickCheck error occurs. Valid characters allowed in the script pathname are letters, digits, and the following special characters: A copy of this script or program will be saved under: lopt/LifeKeeper/subsys/gen/resources/app/actions Whenever this resource is extended to a new server, the copy will be passed to that Cancel NeKt\> ]: media/image56.png {width="6.229166666666667in" height="4.25in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Application Info \[optional\] S4D 00 syncrnem left loqreplay Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back Cancel ]: media/image57.png {width="6.270833333333333in" height="4.208333333333333in"}
  [6]: media/image58.png {width="6.239583333333333in" height="4.229166666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 HANA-S40 Resource Tag Enter a unique name for the resource instance on azsuhanal. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]: media/image59.png {width="6.28125in" height="4.208333333333333in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal /opt/LifeKeeper/lkadm/subsys/gen/app/bin/creapphier azsuhanal /opt/LifeKeeper/HANA2-ARKJrestore.pl /opt/LifeKeeper/HANA2-ARKJremove.pl HANA-S4D S4D 00 syncrnem left logreplay intelligent /opt/LifeKeeper/HANA2-ARKJquickCheck.pl /opt/LifeKeeper/HANA2-ARKJrecover.pl Yes BEGIN create of \"HANA-S40\" creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. ]: media/image60.png {width="6.260416666666667in" height="4.177083333333333in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource HANA-S4D on azsuhanal crea eo creating resource \"HANA-S4D\" resource \"HANA-S4D\" successfully created restoring resource \"HANA-S4D\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal The node azsuhanal is already PRIMARY Master HANA-DB S4D 00 is already running on node azsuhanal Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhanal Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" resource \"HANA-S4D\" restored END successful create of \"HANA-S4D\" Messages produced while creating HANA-SO will be displayed in this dialog and the output panel (if open), and logged on azsuhanal. NeKt\> ]: media/image61.png {width="6.291666666666667in" height="4.21875in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy HANA-S4D on azsuhanal. Select a target server to which the hierarchy will be extended. If you cancel before extending HANA-S4D to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ]: media/image62.png {width="6.28125in" height="4.177083333333333in"}
  [7]: media/image63.png {width="6.3125in" height="4.208333333333333in"}
  [8]: media/image64.png {width="6.3125in" height="4.21875in"}
  [9]: media/image65.png {width="6.302083333333333in" height="4.177083333333333in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for HANA-S4D Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]: media/image66.png {width="6.3125in" height="4.21875in"}
  [Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Resource Tag HANA-S40 Enter a unique name for the resource instance on azsuhana2. The valid characters allowed for the tag are letters, digits, and the following special characters: NeKt\> Accept Defaults Cancel ]: media/image67.png {width="6.302083333333333in" height="4.1875in"}
  [Machine generated alternative text: Extend gen/app Resource Hierarchy\@azsuascs2 Template Server: azsuhanal Tag to Extend: HANA-S40 Target Server: azsuhana2 Application Info \[optional\] S4D 00 syncrnem right loqreplay Enter any optional data for HANA-SO that may be needed by the restore and remove scripts on azsuhana2. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Accept Defaults Cancel ]: media/image68.png {width="6.302083333333333in" height="4.197916666666667in"}
  [Machine generated alternative text: Extend Wizard\@azsuascs2 Extendin resource hierarch HANA-S4D to server azsuhana2 Extending resource instances for HANA-S4D BEGIN extend of \"HANA-S40\" END successful extend of \"HANA-S4D\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (HANA-S4D) Released Hierarchy successfully extended \<Back Accept Defaults ]: media/image69.png {width="6.291666666666667in" height="4.229166666666667in"}
  [10]: media/image70.png {width="6.25in" height="4.229166666666667in"}
  [Machine generated alternative text: Create Dependency\@azsuascs2 NeKt\> Child Resource Tag Cancel ]: media/image71.png {width="6.28125in" height="4.21875in"}
  [Machine generated alternative text: Create Dependency\@azsuascs2 The following dependency will be created: Parent: HANA-S40 child: ip-11.1.2.50 \<Back Cancel ]: media/image72.png {width="6.260416666666667in" height="4.1875in"}
  [Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent HANA-S40 of childi -11.1.2.50 Creating the dependency on the server azsuhanal Creating the dependency on the server azsuhana2 The dependency creation was successful Done ]: media/image73.png {width="6.270833333333333in" height="4.208333333333333in"}
  [11]: media/image74.tmp {width="6.5in" height="0.6361111111111111in"}
  [Machine generated alternative text: Eile Edit Yiew Help ]: media/image75.png {width="5.8125in" height="0.7604166666666666in"}
  [12]: media/image77.png {width="6.28125in" height="4.1875in"}
  [13]: media/image78.png {width="6.28125in" height="4.197916666666667in"}
  [Machine generated alternative text: Create Resource Wizard\@azsuascs2 \<Back NeKt\> Cancel ]: media/image79.png {width="6.291666666666667in" height="4.229166666666667in"}
  [14]: media/image80.png {width="6.28125in" height="4.197916666666667in"}
  [15]: media/image81.png {width="6.3125in" height="4.197916666666667in"}
  [16]: media/image82.png {width="6.302083333333333in" height="4.21875in"}
  [17]: media/image83.png {width="6.302083333333333in" height="4.229166666666667in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 SIOS-SUSE NIC APP-azsuascsl 11.1.2.61 NIC Application Info \[optional\] Enter any optional data for the application resource instance that may be needed by the restore and remove scripts. The valid characters allowed for the data field are letters, digits, and the following special characters: \_ . = \[space\] \<Back NeKt\> Cancel ]: media/image84.png {width="6.28125in" height="4.1875in"}
  [18]: media/image85.png {width="6.28125in" height="4.1875in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Resource Tag Enter a unique name for the resource instance on azsuascsl. The valid characters allowed for the tag are \<Back Create letters, digits, and the following special characters: Cancel Instance ]: media/image86.png {width="6.28125in" height="4.177083333333333in"}
  [Machine generated alternative text: Create gen/app Resource\@azsuascs2 Creatin resource -11.1.2.60 on azsuascsl op e eeper Ip\_genapp recover es BEGIN create of \'lip-11.1.2.60\" creating resource \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" successfully created restoring resource \"ip-11.1.2.60\" BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascsl Note: This process could take up to 2 minutes RTNETLINK answers: File exists INFORMATION: END successful restore of ip-11.1.2.60 on azsuascsl END successful restore of \"ip-11.1.2.60\" resource \"ip-11.1.2.60\" restored END successful create of \"ip-11.1.2.60\" Messages produced while creating ip-11.1.2.60 will be displayed in this dialog and the output panel (if open), and logged on azsuascsl. NeKt\> ]: media/image87.png {width="6.28125in" height="4.197916666666667in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy ip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending ip-11.1.2.60 to at least one provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> other server, LifeKeeper will ]: media/image88.png {width="6.302083333333333in" height="4.197916666666667in"}
  [19]: media/image89.png {width="6.28125in" height="4.197916666666667in"}
  [20]: media/image90.png {width="6.291666666666667in" height="4.208333333333333in"}
  [21]: media/image91.png {width="6.302083333333333in" height="4.25in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for ip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]: media/image92.png {width="6.28125in" height="4.21875in"}
  [22]: media/image93.tmp {width="6.5in" height="1.7777777777777777in"}
  [23]: media/image94.png {width="6.28125in" height="4.229166666666667in"}
  [24]: media/image95.png {width="6.270833333333333in" height="4.260416666666667in"}
  [Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource 11.1.2.60 Enter the IP address or symbolic name to be switched by LifeKeeper. This is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. Cancel NeKt\> ]: media/image96.png {width="6.270833333333333in" height="4.270833333333333in"}
  [Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Netmask 255.255.255.0 Enter or select a network mask for the IP resource. Any standard network mask for the class of the specified IP resource address is valid (IPv4 or IPv6 style addresses). Note: The choice of netmask, combined with the address, determines the subnet to be used by the IP resource and should be consistent with the network configuration. \<Back Cancel ]: media/image97.png {width="6.291666666666667in" height="4.229166666666667in"}
  [Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Network Interface etho Enter or select the network interface that will be used for the IP resource being placed under LifeKeeper protection. The network interface must support the class of the IP address being protected (IPv4 or IPv6 style addresses). The default value is the first valid network interface that LifeKeeper finds on the target server that supports the class of the address being protected. Valid choices will depend on the existing network configuration and the values chosen for the IP resource address and netmask. \<Back Cancel ]: media/image98.png {width="6.302083333333333in" height="4.260416666666667in"}
  [Machine generated alternative text: Create comm/ip Resource\@azsuascs2 IP Resource Tag Enter a unique name that will be used to identify this IP resource instance on azsuascsl. The default tag includes the protected IP address. The valid characters allowed for the tag are letters, digits, and the following special characters: \<Back Cancel Create ]: media/image99.png {width="6.28125in" height="4.229166666666667in"}
  [Machine generated alternative text: Create comm/ip Resource\@azsuascs2 Creatin cornm/i resource\... BEGIN create of \"vip-11.1.2.60\" LifeKeeper application---comm on azsuascsl. LifeKeeper communications resource type= ip on azsuascsl. Creating resource instance with id IR-11.1.2.60 on machine azsuascsl Resource successfully created on azsuascsl BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" END successful create of \"vip-11.1.2.60\". NeKt\> ]: media/image100.png {width="6.291666666666667in" height="4.25in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy vip-11.1.2.60 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending vip-11.1.2.60 to at least one other server, LifeKeeper will provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> ]: media/image101.png {width="6.302083333333333in" height="4.25in"}
  [25]: media/image102.png {width="6.322916666666667in" height="4.260416666666667in"}
  [26]: media/image103.png {width="6.302083333333333in" height="4.322916666666667in"}
  [27]: media/image104.png {width="6.302083333333333in" height="4.260416666666667in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t.. Building independent resource list Checking existence of extend and canextend scripts Checking extendability for vip-11.1.2.60 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]: media/image105.png {width="6.291666666666667in" height="4.28125in"}
  [Machine generated alternative text: e HAN Out of Service\... e Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... ]: media/image106.png {width="3.0833333333333335in" height="2.375in"}
  [28]: media/image107.png {width="6.260416666666667in" height="4.260416666666667in"}
  [Machine generated alternative text: Create Dependency\@azsuascs2 Create De endenc arent vi -11.1.2.60 of child i -11.1.2.60 Creating the dependency on the server azsuascsl The dependency creation was successful Done ]: media/image108.png {width="6.302083333333333in" height="4.322916666666667in"}
  [29]: media/image109.png {width="6.28125in" height="4.260416666666667in"}
  [30]: media/image110.png {width="6.302083333333333in" height="4.197916666666667in"}
  [31]: media/image111.png {width="6.28125in" height="4.197916666666667in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Hierarchy Type Choose the type of data replication hierarchy you wish to create: Replicate New Filesystem creates a new replicated filesystem and makes it accessible on a given mount point. Replicate Existing Filesystem converts an already mounted filesystem into a replicated filesystem. Data Replication Resource creates just a data replication device, with no associated filesystem. The filesystem (or raw disk access) must be configured manually. Cancel NeKt\> ]: media/image112.png {width="6.291666666666667in" height="4.21875in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 ATTENTION! /mnt/resource is not shareable with any other server. using this choice will result in a data replication hierarchy that cannot be extended to other servers to form a shared-storage configuration. To confirm the selection of this entry press Continue. Press Back to select a different entry from the list. \<Back Cancel ]: media/image113.png {width="6.34375in" height="4.25in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Existing Mount Point Select the desired mount point to be replicated. The mount point must already be mounted. \<Back Cancel NeKt\> ]: media/image114.png {width="6.302083333333333in" height="4.1875in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 datarep-Ascsoo Data Replication Resource Tag Enter or select a unique tag name for the data replication resource instance. \<Back Cancel ]: media/image115.png {width="6.302083333333333in" height="4.229166666666667in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 File System Resource Tag usr/sap/S4D/Ascsoo Enter or select a unique tag name for the filesystem resource instance. \<Back Cancel ]: media/image116.png {width="6.302083333333333in" height="4.21875in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Bitmap File /LifeKeeper/bitmap usr sap\_S4D ASCSOO The bitmap file keeps a log of all changed sectors on the disk that have not yet been committed to the target(s). It is useful in the event of a network outage or system downtime because only the changed sectors need to be sent. By default, the bitmap file will contain one bit per 256KB of data on the disk (this can be changed with the LKDR CHUNK SIZE variable). Without a bitmap file, any interruption of the replication process will require a full resynchronization of all mirror targets. \<Back Cancel ]: media/image117.png {width="6.322916666666667in" height="4.21875in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Enable Asynchronous Replication ? no Select whether you want to enable asynchronous replication for this mirror. This is a global option for the entire mirror. Individual targets may be either synchronous or asynchronous. You must select yes if you plan to have any asynchronous targets in this mirror. You should select no if you plan to have on/y synchronous targets. Asynchronous means that writes are signalled as committed when they are safely on the source, but may still be in flight to one or more targets. Asynchronous replication requires a bitmap file. Asynchronous replication is mainly employed in WAN environments. Synchronous means that writes are only signalled as committed when they are safely on the source and all targets. With a synchronous mirror, committed transactions will not be lost even in the event of a server failure. Synchronous mirrors are mainly employed in LAN environments, where the network is fast enough to keep up with the normal write load on the protected filesystem. \<Back Cancel ]: media/image118.png {width="6.3125in" height="4.25in"}
  [Machine generated alternative text: Create Data Replication Resource Hierarchy\@azsuascs2 Creatin Data Re lication Resource\... mount -t Hfs -o /dev/md0 /usr/sap/S4D/Ascsoo devicehier: using /opt/LifeKeeper/lkadm/subsys/scsi/netraid/bin/devicehier to construct the hierarchy WARNING. WARNING: WARNING: WARNING: WARNING. WARNING: WARNING: WARNING: The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. The following mount point(s): /usr/sap/S4D Are above /usr/sap/S4D/ASCS00 but NOT LifeKeeper protected. NeKt\> ]: media/image119.png {width="6.291666666666667in" height="4.1875in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server suasc You have successfully created the resource hierarchy datarep-ASCS00 on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending datarep-ASCS00 to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ]: media/image120.png {width="6.3125in" height="4.197916666666667in"}
  [32]: media/image121.png {width="6.302083333333333in" height="4.21875in"}
  [33]: media/image122.png {width="6.291666666666667in" height="4.177083333333333in"}
  [34]: media/image123.png {width="6.291666666666667in" height="4.208333333333333in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Executin the re-extend scri t\... Building independent resource list Checking existence of extend and canextend scripts Checking extendability for datarep-ASCS00 Checking extendability for /usr/sap/S4D/ASCS00 Pre Extend checks were successful NeKt\> Accept Defaults Cancel ]: media/image124.png {width="6.354166666666667in" height="4.21875in"}
  [35]: media/image125.png {width="6.28125in" height="4.208333333333333in"}
  [36]: media/image126.png {width="6.28125in" height="4.197916666666667in"}
  [37]: media/image127.png {width="6.270833333333333in" height="4.208333333333333in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP SID S4D Select the SAP SID to be protected by LifeKeeper. NeKt\> Cancel ]: media/image128.png {width="6.3125in" height="4.229166666666667in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ASCSOO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ]: media/image129.png {width="6.333333333333333in" height="4.21875in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 IP child resource Select the IP Address for this instance, this is typically the virtual IP address used during installation as specified by the SAPINST LJSE HOSTNAME parameter. \<Back Cancel NeKt\> ]: media/image130.png {width="6.270833333333333in" height="4.239583333333333in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ASCSOO Enter the Tag name for this instance. I ate I \<Back Cancel ]: media/image131.png {width="6.28125in" height="4.239583333333333in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource.. 26.02.2019 StartWait The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function StartWait 22B 5\" command returned \"SUCCESS\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" on \"azsuascsl Please wait.. The \"sapcontrol -format script -prot NI HI-rp -host s4dascs -nr 00 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ASCSOO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The the and END END SAP Instance \"ASCSOO\" and all required processes were started successfully during \"restore\" on server \"azsuascsl Additional information is available in the LifeKeeper system logs. successful restore of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" successful create of \"SAP-S4D ASCSOO\" on server \"azsuascsl \" NeKt\> ]: media/image132.png {width="6.322916666666667in" height="4.302083333333333in"}
  [Machine generated alternative text: Pre- Extend Wizard\@azsuascs2 Target Server You have successfully created the resource hierarchy SAP-S4D ASCSOO on azsuascsl. Select a target server to which the hierarchy will be extended. If you cancel before extending SAP-S4D ASCSOO to at least provide no protection for the applications in the hierarchy. Accept Defaults Cancel NeKt\> one other server, LifeKeeper will ]: media/image133.png {width="6.28125in" height="4.260416666666667in"}
  [38]: media/image134.png {width="6.28125in" height="4.229166666666667in"}
  [39]: media/image135.png {width="6.302083333333333in" height="4.28125in"}
  [40]: media/image136.png {width="6.302083333333333in" height="4.302083333333333in"}
  [Machine generated alternative text: Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ]: media/image137.png {width="6.5in" height="0.9951388888888889in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies unprotected SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo datarep-Ascsoo vip-11.1.2.60 azsusapwitl azsusapwit2 azsu Disconnect\... Refresh.. View Logs\... Create Resource Hierarchy\... Create Comm Path\... Delete Comm Path\... properties\... azsuascs2 ]: media/image138.png {width="6.5in" height="1.4666666666666666in"}
  [41]: media/image139.png {width="6.270833333333333in" height="4.270833333333333in"}
  [42]: media/image140.png {width="6.28125in" height="4.260416666666667in"}
  [43]: media/image141.png {width="6.260416666666667in" height="4.239583333333333in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Instance for S4D ERSIO Select the SAP Instance to be protected by LifeKeeper for the selected SID, S4D. \<Back Cancel ]: media/image142.png {width="6.302083333333333in" height="4.260416666666667in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 AP-S4D ASCSOO Select dependent instances Select the Dependent Central Instance for this application instance, ERSIO. This will create a dependency. \<Back NeKt\> Cancel ]: media/image143.png {width="6.333333333333333in" height="4.291666666666667in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 SAP Tag SAP-S4D ERSIO Enter the Tag name for this instance. I ate I \<Back Cancel ]: media/image144.png {width="6.322916666666667in" height="4.270833333333333in"}
  [Machine generated alternative text: Create SAP Resource\@azsuascs2 Creatin a suite/sa resource\... Preparing to run the command: \"/usr/sap/hostctrl/exe/saphostexec -status\" on \"azsuascsl Please wait\... start hostcontrol using profile /usr/sap/hostctrl/exe/host\_profile saphostexec running (pid = 3130) sapstartsrv running (pid = 3315) saposcol running (pid = 3379) The command \"/usr/sap/hostctrl/exe/saphostexec\" is running on \"azsuascsl Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascsl Please wait\... Warning the profile file /usr/sap/S4D/ERS10/profile/S4D ERSIO s4ders for SID S4D and Instance ERSIO has Autostart is enabled on azsuascsl. Disable Autostart for the specified instance by setting Autostart=0 in the profile file There are no equivalent systems available to perform the \"isSAPRKSRunning\" action for the Replicate Enqueue Instance \"ERSIO\" on \"azsuascsl The resource must be extended to at most one server before this operation can complete END successful restore of \"SAP-S4D ERSIO\" on server \"azsuascsl \" END successful create of \"SAP-S4D ERSIO\" on server \"azsuascsl \" NeKt\> ]: media/image145.png {width="6.3125in" height="4.25in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e vip-11.1.2.60 e /usr/sap/S4D/Ascsoo HANA-S40 azsusapwitl azsusapwit2 azsuascsl azsuascs2 ]: media/image146.png {width="6.5in" height="1.7194444444444446in"}
  [Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Target Disk Select a disk on azsuascs2. The selection must not be mounted and must be at least as large as the source disk on azsuascsl. Accept Defaults Cancel NeKt\> ]: media/image147.png {width="6.3125in" height="4.25in"}
  [Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Data Replication Resource Tag datarep-Ascsoo Enter or select a unique tag name for the data replication \<Back Accept Defaults Cancel resource instance. ]: media/image148.png {width="6.322916666666667in" height="4.260416666666667in"}
  [Machine generated alternative text: Extend Data Replication Resource\@azsuascs2 Template Server: azsuascsl Tag to Extend: datarep-ASCS00 Target Server: azsuascs2 Replication Path Select the network end points to be used for replication between systems azsuascsl and azsuascs2. \<Back NeKt\> Accept Defaults Cancel ]: media/image149.png {width="6.302083333333333in" height="4.270833333333333in"}
  [Machine generated alternative text: Extend comm/ip Resource Hierarchy\@azsuascs2 Template Server: azsuascsl Tag to Extend: vip-11.1.2.60 Target Server: azsuascs2 IP Resource The IP address or symbolic name to be protected by the IP resource on the target server. The same value that was used on the template server is used for the IP resource on the target server. Therefore, this value cannot be changed. The IP resource is used by client applications to login into the parent application over a specific network interface. If a symbolic name is used, it must exist in the local /etc/hosts file or be accessible via a Domain Name Server (DNS). Any valid hosts file entry, including aliases, is acceptable. If the address cannot be determined or if it is found to be already in use, it will be rejected. If a symbolic name is given, it is used for translation to an IP address and is not retained by LifeKeeper. Both IPv4 and IPv6 style addresses are supported. NeKt\> Accept Defaults Cancel ]: media/image150.png {width="6.291666666666667in" height="4.229166666666667in"}
  [Machine generated alternative text: Eile Edit Yiew Help Hierarchies Not Active datarep-Ascsoo SAP-S4D ASCSOO SAP-S4D ERSIO vip-11.1.2.60 SAP-S4D ERSIO azsusapwitl azsusapwit2 azsuascsl azsuascs2 azsuhanal azsuhana2 ]: media/image151.png {width="6.5in" height="1.007638888888889in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit Yiew Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 azsusapwitl azsusapwit2 Extend Wizard\@azsuascs2 azsuascsl azsuascs2 azsuhanal azsuhana2 Extendin resource hierarch -11.1.2.60 to server azsuascs2 Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/create\_ins\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/depstoeHtend\" on \"azsuascs2\". Please wait\... Preparing to run the command: \"/opt/LifeKeeper/lkadm/subsys/genftilesys/bin/eHtend\" on \"azsuascs2\". Please wait\... BEGIN extend of \'lip-11.1.2.60\" END successful extend of \"ip-11.1.2.60\" Creating dependencies Setting switchback type for hierarchy Creating equivalencies LifeKeeper Admin Lock (SAP-S4D ERSIO) Released Hierarchy successfully extended Next Server Accept Defaults ]: media/image152.png {width="6.5in" height="2.8319444444444444in"}
  [Machine generated alternative text: Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S In Service.. e ip-l Out of Service\... Extend Resource Hierarchy\... unextend Resource Hierarchy\... Create Dependency\... Delete Dependency\... Delete Resource Hierarchy\... properties\... azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ]: media/image153.png {width="6.5in" height="1.8180555555555555in"}
  [Machine generated alternative text: InService\@azsuascs2 NeKt\> Cancel ]: media/image154.png {width="6.313194444444444in" height="4.209027777777778in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 Confirm in service action for Server: azsuhana2 Resource: HANA-S40 azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 \<Back Cancel ]: media/image155.png {width="6.5in" height="4.277777777777778in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service Done azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 ]: media/image156.png {width="6.5in" height="4.279166666666667in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--private-ip-address 11.1.2.50 azsuhanal azsuhana2 e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in HANA-S4D in service on azsuhana2 Put resource \"HANA-S4D\" in-service BEGIN restore of \'lip-11.1.2.50\" INFORMATION: BEGIN restore of ip-11.1.2.50 on azsuhana2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.50 on azsuhana2 END successful restore of \"ip-11.1.2.50\" BEGIN restore of \"HANA-S40\" restore for HANA-S4D started SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Done \--nic-name NIC APP-azsuhana2 \--name ipconfig2 \> /dev/null 2\>&1) on azsuhanal ]: media/image157.png {width="6.5in" height="4.285416666666666in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 n Service\@azsuascs2 azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 Brin in HANA-S4D in service on azsuhana2 SAP host agent is running on node azsuhana2 sapstartsrv for instance S4D 00 is running on node azsuhana2 Takeover of System Replication started on node azsuhana2 Node azsuhana2 is now PRIMARY master Takeover of System Replication finished successful on node azsuhana2 HANA-DB S4D 00 is already running on node azsuhana2 DEBUG\[0524\]: getRemoteHostParmName: set profileHostName=azsuhana2. dflt=azsuhana2 Replication mode on node azsuhanal is now syncrnem Reenable system replication on node azsuhanal finished successful Node azsuhanal is now registered in system replication mode syncrnem at node azsuhana2 SAP host agent is running on node azsuhanal sapstartsrv for instance S4D 00 is running on node azsuhanal Starting HANA-DB S4D 00 on node azsuhanal Start of HANA-DB S4D 00 on node azsuhanal successful Create LifeKeeper flag \"!volatile!noHANAremove HANA-S4D\" on node azsuhana2 Restore for resorce HANA-S4D finished END successful restore of \"HANA-S4D\" Put \"HANA-S4D\" in-service successful Done ]: media/image158.png {width="6.5in" height="4.280555555555556in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D SAP-S e e HANA-S4 update Protection Level update Recoveru Level Handle Warnings SSCC HA Actions In Service\... Out of Service\... Extend Resource Hierarchy.. unextend Resource Hierarchy\... Create Dependency.. Delete Dependency\... Delete Resource Hierarchy.. properties\... ]: media/image159.png {width="6.5in" height="1.6159722222222221in"}
  [44]: media/image160.png {width="6.283333333333333in" height="4.216666666666667in"}
  [Machine generated alternative text: n Service\@azsuascs2 Confirm in service action for Server: azsuascs2 Resource: SAP-S4D ERSIO (SAPID-S40-ERSIO) \<Back Cancel ]: media/image161.png {width="6.30625in" height="4.19375in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS Done ]: media/image162.png {width="6.5in" height="2.525in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target azsuhanal azsuhana2 e /usr/sap/S4D/Ascsoo e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Put resource \"SAP-S4D ERSIO\" in-service Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Done ]: media/image163.png {width="6.5in" height="2.5743055555555556in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Not Active SAP-S4D ERSIO SAP-S4D ASCSOO /usr/sap/S4D/Ascsoo azsusapwitl azsusapwit2 azsuascsl azsuascs2 Target \--name S4DASCS \> /dev/null 2\>&1) on azsuascsl azsuhanal azsuhana2 e datarep-Ascsoo vip-11.1.2.60 HANA-S40 InService\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 Communication failure: destination system \"azsuersl \" is out of service. Lock for azsuersl is ignored because system is OOS BEGIN restore of \'lip-11.1.2.60\" INFORMATION: BEGIN restore of ip-11.1.2.60 on azsuascs2 Note: This process could take up to 2 minutes Running command (az network nic ip-config create \--resource-group SIOS-SUSE INFORMATION: END successful restore of ip-11.1.2.60 on azsuascs2 END successful restore of \"ip-11.1.2.60\" BEGIN restore of \"vip-11.1.2.60\" END successful restore of \"vip-11.1.2.60\" Done \--nic-name NIC APP-azsuersl \--private-ip-address 11.1.2.60 ]: media/image164.png {width="6.5in" height="2.647222222222222in"}
  [Machine generated alternative text: LifeKeeper GUI\@azsuascs2 Eile Edit View Help Hierarchies Active Protected SAP-S4D ERSIO SAP-S4D ASCSOO e /usr/sap/S4D/Ascsoo Target azsusapwitl n Service\@azsuascs2 Brin in SAP-S4D ERSIO in service on azsuascs2 saposcol running (pid = 1979) azsusapwit2 azsuascsl azsuascs2 azsuhanal azsuhana2 e datarep-Ascsoo e vip-11.1.2.60 HANA-S40 The command \"/usr/sap/hostctrl/exe/saphostexec\" is running on \"azsuascsl Additional information is available in the LifeKeeper and system logs. Preparing to run the command: \"/usr/sap/hostctrl/exe/saposcol -s on \"azsuascsl Please wait.. Preparing to run the command: \"sapcontrol -format script -prot NI HI-rp -host azsuascsl -nr 10 -function GetProcessList\" on \"azsuascsl Please wait\... The \"sapcontrol -format script -prot NI HI-rp -host azsuascsl -nr 10 -function GetProcessList\" command returned \"3\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs All processes for SAP SID \"S4D\" and Instance \"ERSIO\" are \"running\" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The \"SAPInstanceCmd\" command returned \"1 \" on \"azsuascsl Additional information is available in the LifeKeeper and system logs The \"/opt/LifeKeeper/lkadm/subsys/appsuite/sap/bin/remoteControl SAP-S4D ERSIO ERSIO \"SAPInstanceCmd\" \"start\" \"azsuascsl \" \"SAP-S4D ERSIO\" command returned \"1 \" on \"azsuascs2\". Additional information is available in the LifeKeeper and system logs The SAP Instance \"ERSIO\" and all required processes were started successfully during the \"restore\" on server \"azsuascs2\". Additional information is available in the LifeKeeper and system logs. END successful restore of \"SAP-S4D ERSIO\" on server \"azsuascs2\" Put \"SAP-S4D ERSIO\" in-service successful Done ]: media/image165.png {width="6.5in" height="2.520138888888889in"}
