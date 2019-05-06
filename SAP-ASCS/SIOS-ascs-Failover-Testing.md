# SAP ASCS Failover

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