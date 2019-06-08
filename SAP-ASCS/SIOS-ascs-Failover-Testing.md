# SAP ASCS Failover

In the (A)SCS HA configuration shown below, The SAP System S4D's ASCS is running on the virutal hostname for Node-1 (S4DASCS) using the instance profile (S4D_ASCS00_S4DASCS) and the SAP ERS is running on the local hostname for Node-2 (AZSUASCS2) using the instance profile (S4D_ERS10_AZSUASCS2). The File System required to failover the SAP ASCS /usr/sap/S4D/ASCS00 is being replicated from Node-1 to Node-2.

![ASCS-SIOS](/99_images/Slide1.png)

Upon AZSUASCS1 node-1 Failure

![ASCS-SIOS](/99_images/Slide2.png)

Upon AZSUASCS1 node-1 Comes back

![ASCS-SIOS](/99_images/Slide3.png)

Upon AZSUASCS2 node-2 Failure

![ASCS-SIOS](/99_images/Slide4.png)

![ ](/SAP-ASCS/Images/failover-ascs-1.png)

![ ](/SAP-ASCS/Images/failover-ascs-2.png)

![ ](/SAP-ASCS/Images/failover-ascs-3.png)

![ ](/SAP-ASCS/Images/failover-ascs-4.png)

![ ](/SAP-ASCS/Images/failover-ascs-5.png)

Node-1:

```bash
/usr/sap/S4D/ASCS00/exe/sapcontrol -prot NI_HTTP -nr 00 -function GetProcessList
```

```console
06.05.2019 09:49:04
GetProcessList
OK
name, description, dispstatus, textstatus, starttime, elapsedtime, pid
msg_server, MessageServer, GREEN, Running, 2019 05 06 09:41:01, 0:08:03, 68226
enserver, EnqueueServer, GREEN, Running, 2019 05 06 09:41:01, 0:08:03, 68227
sapwebdisp, Web Dispatcher, GREEN, Running, 2019 05 06 09:41:01, 0:08:03, 68228
gwrd, Gateway, GREEN, Running, 2019 05 06 09:41:01, 0:08:03, 68229
```

Node-2

```bash
/usr/sap/S4D/ERS10/exe/sapcontrol -prot NI_HTTP -nr 10 -function GetProcessList
```

```console
06.05.2019 09:47:46
GetProcessList
OK
name, description, dispstatus, textstatus, starttime, elapsedtime, pid
enrepserver, EnqueueReplicator, GREEN, Running, 2019 05 06 09:41:42, 0:06:04, 123851
```
