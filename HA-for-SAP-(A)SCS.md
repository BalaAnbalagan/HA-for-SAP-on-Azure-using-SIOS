# High Availability Solution for SAP NetWeaver (RHEL & SuSE) on Azure using SIOS Protection Suite

### 1. SAP ASCS Clustering
![ASCS](/99_images/ASCS1.png)

## 10. SAP ASCS/ERS cluster configuration


### 1. Create floating IP for ASCS
     

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
<pre><code>
ip add show
</code></pre>
<pre><code>
1: lo: \<LOOPBACK,UP,LOWER\_UP\> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
inet 127.0.0.1/8 scope host lo
valid\_lft forever preferred\_lft forever
inet6 ::1/128 scope host
valid\_lft forever preferred\_lft forever
2: eth0: \<BROADCAST,MULTICAST,UP,LOWER\_UP\> mtu 1500 qdisc mq state UP group default qlen 1000
link/ether 00:0d:3a:06:27:29 brd ff:ff:ff:ff:ff:ff
inet 11.1.2.61/24 brd 11.1.2.255 scope global eth0
valid\_lft forever preferred\_lft forever
inet 11.1.2.60/24 scope global secondary eth0
valid\_lft forever preferred\_lft forever
inet6 fe80::20d:3aff:fe06:2729/64 scope link
valid\_lft forever preferred\_lft forever
</code></pre>

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
