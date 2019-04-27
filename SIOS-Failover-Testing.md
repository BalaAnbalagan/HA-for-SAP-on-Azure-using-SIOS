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