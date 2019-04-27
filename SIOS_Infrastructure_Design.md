## 2. Reference Architecture

  |Components     | hostname     | IP address |  VIP       |  VHOSTNAME |
  | --------------| -------------|------------| -----------|----------- |
  |SAP ASCS Pool  | azsuascs1    | 11.1.2.61  |  11.1.2.60 |  s4dascs   |
  |               | azsuascs2    | 11.1.2.62  |            |            |  
  |SAP App Pool   | azsusap1     | 11.1.2.53  |            |            |
  |               | azsusap2     | 11.1.2.54  |            |            |
  |SAP DB Pool    | azsuhana1    | 11.1.2.51  |  11.1.2.50 |  s4ddb     |
  |               | azsuhana2    | 11.1.2.52  |            |            |
  |SIOS Witness   | azsusapwit1  | 11.1.2.65  |            |            |
  |               | azsusapwit2  | 11.1.2.66  |            |            |
  |NFS            | pg-nfs       | 11.1.1.11  |            |            |
  |DNS            | pg-dns       | 11.1.1.5   |            |            |
  |Jumpbox        | pg-rdp00     | 11.0.1.5   |            |            |

> The reference architecture consists of the following infrastructure and key software components.

### 1. Version Table
-------------
  | Components                     | Release |  SPS/Patch|
  | ------------------------------ |:-------:|----------:|
  |SAP S/4 HANA                    | 1709    | 00        |
  |SAP HANA DB                     |  2.0    | 03        |
  |SAP Kernel                      |  753    | 300       |
  |SIOS Protection Suite for Linux |  9.3.1  |           |
  |SIOS HANA2.0 ARK                |  2.0    |           |
  |SIOS Enhanced Azure Gen App     | 2.4     |           |

### 1. Virtual IP & Hostnames
  
    Create the following A-Record in your DNS or create host enties in /etc/hosts file.

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