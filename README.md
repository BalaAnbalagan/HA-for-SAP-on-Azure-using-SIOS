
# High Availability Solution for SAP NetWeaver (RHEL, OEL & SuSE*) & SAP HANA (RHEL & SuSE) on Azure using SIOS Protection Suite


## 1. Introduction
> This document describes the procedure to implement High Availability Solution to protect SAP NW & SAP HANA on Azure using SIOS Protection Suite (SPS) for Linux. "SIOS Enhanced Azure Gen App" is used to switch IP address between cluster nodes instead using of Azure Internal Load balancer.
>
> The solution is certified by SAP for the following versions of Operating Systems. please refer SAP Note 1662610 <https://launchpad.support.sap.com/#/notes/1662610>

1.  Red Hat Enterprise Linux Server 7.4 (Maipo)

2.  SUSE Linux Enterprise Server 12 SP3

> Note:
>
> 
> - The steps in this document is suitable and similar for RHEL 7.4 as well
>
> - SAP installation screens not included as i used silent installation.
>
> - run sapinst with SAPINST\_USE\_HOSTNAME=\<virtual hostname\> for SAP ASCS installation

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

### 5.  Reference Architecture Diagram
    
   >![Archtecture Diagram](/99_images/arch.png)
   >This document uses SuSE landscape for illustration

### 6. [Infrastructure Provisioning](https://github.com/BalaAnbalagan/HA-for-SAP-on-Azure-using-SIOS)

## 3. SIOS Clustering Basics

### 1. SIOS PORTS

GUI PORT 81 & 82
Remote Method Inovaction PORT 1024
Internode Communications 778 can be changed API_SSL_PORT in configuration variable /etc/default/LifeKeeper

LifeKeeper Data Replication
When using LifeKeeper Data Replication, the firewall should be configured to allow access to any of the ports used by nbd for replication.  The ports used by nbd can be calculated using the following formula:

10001 + \<mirror number\> + <256 * i>

where i starts at zero and is incremented until the formula calculates a port number that is not in use.  In use constitutes any port found defined in /etc/services, found in the output of netstat -an --inet, or already defined as in use by another LifeKeeper Data Replication resource.

For example: If the mirror number for the LifeKeeper Data Replication resource is 0, then the formula would initially calculate the port to use as 10001, but that number is defined in /etc/services on some Linux distributions as the SCP Configuration port.  In this case, i is incremented by 1 resulting in Port Number 10257, which is not in /etc/services on these Linux distributions.

### 2. I/O Fencing
I/O fencing is the locking away of data from a malfunctioning node preventing uncoordinated access to shared storage. In an environment where multiple servers can access the same data, it is essential that all writes are performed in a controlled manner to avoid data corruption. Problems can arise when the failure detection mechanism breaks down because the symptoms of this breakdown can mimic a failed node. For example, in a two-node cluster, if the connection between the two nodes fails, each node would “think” the other has failed, causing both to attempt to take control of the data resulting in data corruption. I/O fencing removes this data corruption risk by blocking access to data from specific nodes.
In principle, I/O fencing using storage reservations is not available in DataKeeper configuration and split brain can occur. Therefore, you need to take steps to prevent a split brain from occurring via the following controls.

#### 1. Exclusive Control using IP Resources
IP resources have an exclusive control functionality using duplication checking to ensure the same IP resource is not activated on multiple nodes. This can be used to avoid a split brain with DataKeeper resources.
Adding an IP resources as a child resource to all DataKeeper resources in the hierarchy can prevent the DataKeeper resource from starting on multiple nodes at the same time. 
This method can only be used in environments where all the nodes in the cluster reside in the same subnet. This is required to perform the duplicate IP address checking.



#### 2. Exclusive Control with Quorum/Witness Functionality
You can use the quorum/witness functionality in LifeKeeper to prevent multiple nodes from becoming active at the same time. 


### 2. Quorum/Witness 
The Quorum/Witness Server Support Package for LifeKeeper (steeleye-lkQWK, hereinafter “Quorum/Witness Package”) combined with the existing failover process of the LifeKeeper core allows system failover to occur with a greater degree of confidence in situations where total network failure could be common. This effectively means that local site failovers and failovers to nodes across a WAN can be done while greatly reducing the risk of “split-brain” situations.

In a distributed system that takes network partitioning into account, there is a concept called quorum to obtain consensus across the all cluster. A node having quorum is a node that can obtain consensus of all the clusters and is allowed to bring resources in service. On the other hand, a node not having quorum is a node that cannot obtain consensus of all the clusters and it is not allowed to bring resources in service. This will prevent split brain from happening. To check whether a node has quorum is called quorum check. It is expressed as “quorum check succeeded” if it has quorum, and “quorum check failed” if it does not have quorum.

In case of a communication failure, using one node where failure occurred and another multiple nodes (or other devices) will allow a node to get a “second opinion” on the status of the failing node. The node to get a “second opinion” is called a witness node (or a witness device), and getting a “second opinion” is called witness checking. When determining when to fail over, the witness node (the witness device) allows resources to be brought in service on a backup server only in cases where it verifies the primary server has failed and is no longer part of the cluster. This will prevent failovers from happening due to simple communication failures between nodes when those failures don’t affect the overall access to, and performance of, the in-service node. During actual operation, the witness node (the witness device) will be consulted when LifeKeeper is started or the failed communication path is restored. Witness checking can only be performed for nodes having quorum.
### 3. Datakeeper

### 4. STONITH (Testing in-progress)
STONITH (Shoot The Other Node in the Head) is a fencing technique for remotely powering down a node in a cluster. LifeKeeper can provide STONITH capabilities by using external power switch controls, IPMI-enabled motherboard controls and hypervisor-provided power capabilities to power off the other nodes in a cluster.

#### 1. Installation and Configuration
After installing LifeKeeper and configuring communication paths for each node in the cluster, install and configure STONITH.

Install the LifeKeeper STONITH script by running the following command:

/opt/LifeKeeper/samples/STONITH/stonith-install

#### 2. Edit the configuration file
Update the configuration file to enable STONITH and add the power off command line. Note: Power off is recommended over reboot to avoid fence loops (i.e. two machines have lost communication but can still STONITH each other, taking turns powering each other off and rebooting).
<pre><code>
cat /opt/LifeKeeper/config/stonith.conf
</code></pre>

```console
# LifeKeeper STONITH configuration
#
# Each system in the cluster is listed below. To enable STONITH for a
# given system,
# remove the '#' on that line and insert the STONITH command line to power off
# that system.
# Example1 : Azure CLI Command
az vm stop -n azsuers1 -g SIOS-SUSE --no-wait
#EOF
```

The SIOS Protection Suite will protect the ASCS instance. The S4D_ASCS00 instance will have /usr/sap/S4D/ASCS00 data replication and IP Resource with Azure IP Gen App resource as child.
## 4. [Infrastructure Provisioning](https://github.com/BalaAnbalagan/SAP-on-Azure-using-Terraform)
## 5. [Azure CLI Installation for Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
## 6. [Install SIOS Protection Suite 9.3.1](Install_SIOS.md)
## 7. [SAP HANA Database Cluster Configuration](HA-for-SAP-HANA-DB.md)
## 8. [SAP A(SCS) Cluster Configuration](HA-for-SAP-(A)SCS.md)
## 9. [SAP Failover Testing](SIOS-Failover-Testing.md)