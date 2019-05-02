# Create SAP Resource S4D-ASCS

![ ](/99_images/create-sap-res-s4d-ascs00-1.png)

![ ](/99_images/create-sap-res-s4d-ascs00-2.png)

![ ](/99_images/create-sap-res-s4d-ascs00-3.png)

![ ](/99_images/create-sap-res-s4d-ascs00-4.png)

![ ](/99_images/create-sap-res-s4d-ascs00-5.png)

![ ](/99_images/create-sap-res-s4d-ascs00-6.png)

![ ](/99_images/create-sap-res-s4d-ascs00-7.png)

![ ](/99_images/create-sap-res-s4d-ascs00-8.png)

![ ](/99_images/create-sap-res-s4d-ascs00-9.png)

![ ](/99_images/create-sap-res-s4d-ascs00-10.png)

![ ](/99_images/create-sap-res-s4d-ascs00-11.png)

![ ](/99_images/create-sap-res-s4d-ascs00-12.png)

![ ](/99_images/create-sap-res-s4d-ascs00-13.png)

![ ](/99_images/create-sap-res-s4d-ascs00-14.png)

![ ](/99_images/create-sap-res-s4d-ascs00-15.png)

![ ](/99_images/create-sap-res-s4d-ascs00-16.png)

![ ](/99_images/create-sap-res-s4d-ascs00-17.png)

![ ](/99_images/create-sap-res-s4d-ascs00-18.png)

![ ](/99_images/create-sap-res-s4d-ascs00-19.png)

![ ](/99_images/create-sap-res-s4d-ascs00-20.png)

![ ](/99_images/create-sap-res-s4d-ascs00-21.png)

![ ](/99_images/create-sap-res-s4d-ascs00-22.png)

```bash
/usr/sap/S4D/ASCS00/exe/sapcontrol -prot NI_HTTP -nr 00 -function GetProcessList
```

```console
01.05.2019 22:27:50
GetProcessList
OK
name, description, dispstatus, textstatus, starttime, elapsedtime, pid
msg_server, MessageServer, GREEN, Running, 2019 05 01 22:20:38, 0:07:12, 114628
enserver, EnqueueServer, GREEN, Running, 2019 05 01 22:20:38, 0:07:12, 114629
sapwebdisp, Web Dispatcher, GREEN, Running, 2019 05 01 22:20:38, 0:07:12, 114630
gwrd, Gateway, GREEN, Running, 2019 05 01 22:20:38, 0:07:12, 114631
```

```bash
ps -aef|grep s4dadm
```

```console
s4dadm    18460      1  0 14:57 ?        00:00:04 /usr/sap/S4D/ERS10/exe/sapstartsrv pf=/usr/sap/S4D/ERS10/profile/S4D_ERS10_azsuascs1 -D -u s4dadm
s4dadm   105553      1  0 22:11 ?        00:00:00 /usr/lib/systemd/systemd --user
s4dadm   105555 105553  0 22:11 ?        00:00:00 (sd-pam)
s4dadm   105672      1  0 22:11 ?        00:00:01 /usr/sap/S4D/ASCS00/exe/sapstartsrv pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS -D -u s4dadm
s4dadm   114613      1  0 22:20 ?        00:00:00 sapstart pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS
s4dadm   114628 114613  0 22:20 ?        00:00:00 ms.sapS4D_ASCS00 pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS
s4dadm   114629 114613  0 22:20 ?        00:00:00 en.sapS4D_ASCS00 pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS
s4dadm   114630 114613  0 22:20 ?        00:00:01 wd.sapS4D_ASCS00 pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS
s4dadm   114631 114613  0 22:20 ?        00:00:00 gw.sapS4D_ASCS00 pf=/usr/sap/S4D/SYS/profile/S4D_ASCS00_S4DASCS -abap
root     120338   5773  0 22:27 pts/1    00:00:00 su - s4dadm
s4dadm   120339 120338  0 22:27 pts/1    00:00:00 -csh
s4dadm   123226 120339 99 22:29 pts/1    00:00:00 ps -aef
s4dadm   123227 120339  0 22:29 pts/1    00:00:00 grep s4dadm
```