## 10. Install SAP Components
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
