# SIOS Clustering Basics [Abstract from SIOS Doc website](http://docs.us.sios.com/Linux/9.3.1/LK4L/TechDoc/index.htm#introduction.htm%3FTocPath%3DIntroduction%7C_____0)

## Lifekeeper Core
LifeKeeper Core is composed of four major components:

- LifeKeeper Core Software

- File System, Generic Application, Raw I/O and IP Recovery Kit Software

- LifeKeeper GUI Software

- LifeKeeper Man Pages

### LifeKeeper Core Software
The LifeKeeper Core Software consists of the following components:

- LifeKeeper Configuration Database (LCD) - The LCD stores information about the LifeKeeper-protected resources.  This includes information on resource instances, dependencies, shared equivalencies, recovery direction, and LifeKeeper operational flags.  The data is cached in shared memory and stored in files so that the data can be remembered over system boots.

- LCD Interface (LCDI) - The LCDI queries the configuration database (LCD) to satisfy requests for data or modifications to data stored in the LCD.  The LCDI may also be used by the Application Recovery Kit to obtain resource state or description information.

- LifeKeeper Communications Manager (LCM) - The LCM is used to determine the status of servers in the cluster and for LifeKeeper inter-process communication (local and remote).  Loss of LCM communication across all communication paths on a server in the cluster indicates the server has failed.

- LifeKeeper Alarm Interface - The LifeKeeper Alarm Interface provides the infrastructure for triggering an event.  The sendevent program is called by application daemons when a failure is detected in a LifeKeeper-protected resource.  The sendevent program communicates with the LCD to determine if recovery scripts are available.

- LifeKeeper Recovery Action and Control Interface (LRACI) - The LRACI determines the appropriate recovery script to execute for a resource and invokes the appropriate restore / remove scripts for the resource.

### File System, Generic Application, IP and RAW I/O Recovery Kit Software
The LifeKeeper Core provides protection of specific resources on a server. These resources are:

- File Systems - LifeKeeper allows for the definition and failover of file systems on shared storage devices.  A file system can be created on a disk that is accessible by two servers via a shared SCSI bus.  A LifeKeeper file system resource is created on the first server and then extended to the second server. File System Health Monitoring detects disk full and improperly mounted (or unmounted) file system conditions.  Depending on the condition detected, the Recovery Kit may log a warning message, attempt a local recovery, or failover the file system resource to the backup server.

- Specific help topics related to the File System Recovery Kit include Creating and Extending a File System Resource Hierarchy and File System Health Monitoring.

- Generic Applications  - The Generic Application Recovery Kit allows protection of a generic or user-defined application that has no predefined Recovery Kit to define the resource type.  This kit allows a user to define monitoring and recovery scripts that are customized for a specific application.

Specific help topics related to the Generic Application Recovery Kit include Creating and Extending a Generic Application Resource Hierarchy.

- IP Addresses - The IP Recovery Kit provides a mechanism to recover a "switchable" IP address from a failed primary server to one or more backup servers in a LifeKeeper environment.  A switchable IP address is a virtual IP address that can switch between servers and is separate from the IP address associated with the network interface card of each server.  Applications under LifeKeeper protection are associated with the switchable IP address, so if there is a failure on the primary server, the switchable IP address becomes associated with the backup server.  The resource under LifeKeeper protection is the switchable IP address. 

Refer to the IP Recovery Kit Technical Documentation included with the Recovery Kit for a specific product, configuration and administration information.

- RAW I/O - The RAW I/O Recovery Kit provides support for raw I/O devices for applications that prefer to bypass kernel buffering.  The RAW I/O Recovery Kit allows for the definition and failover of raw devices bound to shared storage devices.  The raw device must be configured on the primary node prior to resource creation.  Once the raw resource hierarchy is created, it can be extended to additional servers.

- Quick Service Protection (QSP) - QSP Recovery Kit provides a mechanism to simply protect OS services. Resources can be created for services that can be started/stopped with OS service commands. Generic Applications can provide the same protection, but QSP doesn’t require code development. Also, you can create dependencies to start/stop services with applications protected by other resources.

However, QuickCheck of QSP only performs a simple check (using service command’s “status”) and does not ensure the provision of the services and running of the processes. If complicated start/stop processing or robust check is required, please consider the use of Generic Applications.

For other topics regarding QSP, please see “Creating/extending QSP resources.”

 

### LifeKeeper GUI Software
The LifeKeeper GUI is a client / server application developed using Java technology that provides a graphical administration interface to LifeKeeper and its configuration data.  The LifeKeeper GUI client is implemented as both a stand-alone Java application and as a Java applet invoked from a web browser.

## I/O Fencing
I/O fencing is the locking away of data from a malfunctioning node preventing uncoordinated access to shared storage. In an environment where multiple servers can access the same data, it is essential that all writes are performed in a controlled manner to avoid data corruption. Problems can arise when the failure detection mechanism breaks down because the symptoms of this breakdown can mimic a failed node. For example, in a two-node cluster, if the connection between the two nodes fails, each node would “think” the other has failed, causing both to attempt to take control of the data resulting in data corruption. I/O fencing removes this data corruption risk by blocking access to data from specific nodes.
In principle, I/O fencing using storage reservations is not available in DataKeeper configuration and split brain can occur. Therefore, you need to take steps to prevent a split brain from occurring via the following controls.

### 1. Exclusive Control using IP Resources
IP resources have an exclusive control functionality using duplication checking to ensure the same IP resource is not activated on multiple nodes. This can be used to avoid a split brain with DataKeeper resources.
Adding an IP resources as a child resource to all DataKeeper resources in the hierarchy can prevent the DataKeeper resource from starting on multiple nodes at the same time. 
This method can only be used in environments where all the nodes in the cluster reside in the same subnet. This is required to perform the duplicate IP address checking.



### 2. Exclusive Control with Quorum/Witness Functionality
You can use the quorum/witness functionality in LifeKeeper to prevent multiple nodes from becoming active at the same time. 


## Quorum/Witness 
The Quorum/Witness Server Support Package for LifeKeeper (steeleye-lkQWK, hereinafter “Quorum/Witness Package”) combined with the existing failover process of the LifeKeeper core allows system failover to occur with a greater degree of confidence in situations where total network failure could be common. This effectively means that local site failovers and failovers to nodes across a WAN can be done while greatly reducing the risk of “split-brain” situations.

In a distributed system that takes network partitioning into account, there is a concept called quorum to obtain consensus across the all cluster. A node having quorum is a node that can obtain consensus of all the clusters and is allowed to bring resources in service. On the other hand, a node not having quorum is a node that cannot obtain consensus of all the clusters and it is not allowed to bring resources in service. This will prevent split brain from happening. To check whether a node has quorum is called quorum check. It is expressed as “quorum check succeeded” if it has quorum, and “quorum check failed” if it does not have quorum.

In case of a communication failure, using one node where failure occurred and another multiple nodes (or other devices) will allow a node to get a “second opinion” on the status of the failing node. The node to get a “second opinion” is called a witness node (or a witness device), and getting a “second opinion” is called witness checking. When determining when to fail over, the witness node (the witness device) allows resources to be brought in service on a backup server only in cases where it verifies the primary server has failed and is no longer part of the cluster. This will prevent failovers from happening due to simple communication failures between nodes when those failures don’t affect the overall access to, and performance of, the in-service node. During actual operation, the witness node (the witness device) will be consulted when LifeKeeper is started or the failed communication path is restored. Witness checking can only be performed for nodes having quorum.
### Datakeeper
SIOS DataKeeper for Linux provides an integrated data mirroring capability for LifeKeeper environments.  This feature enables LifeKeeper resources to operate in shared and non-shared storage environments.

#### Mirroring with SIOS DataKeeper for Linux
SIOS DataKeeper for Linux offers an alternative for customers who want to build a high availability cluster (using SIOS LifeKeeper) without shared storage or who simply want to replicate business-critical data in real-time between servers. 

SIOS DataKeeper uses either synchronous or asynchronous volume-level mirroring to replicate data from the primary server (mirror source) to one or more backup servers (mirror targets).  

##### DataKeeper Features
SIOS DataKeeper includes the following features:

- Allows data to be reliably, efficiently and consistently mirrored to remote locations over any TCP/IP-based Local Area Network (LAN) or Wide Area Network (WAN).

- Supports synchronous or asynchronous mirroring.

- Transparent to the applications involved because replication is done at the block level below the file system.

- Supports multiple simultaneous mirror targets including cascading failover to those targets when used with LifeKeeper.

- Built-in network compression allows higher maximum throughput on Wide Area Networks.

- Supports all major file systems (see the SPS for Linux Release Notes product description for more information regarding journaling file system support).

- Provides failover protection for mirrored data.

- Integrates into the LifeKeeper Graphical User Interface.

- Fully supports other LifeKeeper Application Recovery Kits.

- Automatically resynchronizes data between the primary server and backup servers upon system recovery.

- Monitors the health of the underlying system components and performs a local recovery in the event of failure.

- Supports STONITH devices for I/O fencing. For details, refer to the STONITH topic. 

#### Synchronous vs. Asynchronous Mirroring
Understanding the differences between synchronous and asynchronous mirroring will help you choose the appropriate mirroring method for your application environment.

##### Synchronous Mirroring
SIOS DataKeeper provides real-time mirroring by employing a synchronous mirroring technique in which data is written simultaneously on the primary and backup servers. For each "Write operation", DataKeeper forwards the write program to the target device(s) and awaits remote confirmation before signaling I/O completion.  The advantage of synchronous mirroring is a high level of data protection because it ensures that all copies of the data are always identical. However, the performance may suffer due to the wait for remote confirmation, particularly in a WAN environment.

##### Asynchronous Mirroring
With asynchronous mirroring, each write is made to the source device and then a copy is queued to be transmitted to the target device(s). This means that at any given time, there may be numerous committed write transactions that are waiting to be sent from the source to the target device.  The advantage of asynchronous mirroring is better performance because writes are acknowledged when they reach the primary disk, but it can be less reliable because if the primary system fails, any writes that are in the asynchronous write queue will not be transmitted to the target. To mitigate this issue, SIOS DataKeeper makes an entry to an intent log file for every write made to the primary device.If a large amount of data is written, the I/O performance may decrease temporarily because that data takes priority in the queue for transmission to the other nodes.

The intent log is a bitmap file indicating which data blocks are out of sync between the primary and target mirrors. In the event of a server failure, the intent log can be used to avoid a full resynchronization (or resync) of the data.


### 4. STONITH (Testing in-progress)
STONITH (Shoot The Other Node In The Head) is a fencing technique for remotely powering down a node in a cluster. LifeKeeper can provide STONITH capabilities by using external power switch controls, IPMI-enabled motherboard controls and hypervisor-provided power capabilities to power off the other nodes in a cluster.

#### 1. Installation and Configuration
After installing LifeKeeper and configuring communication paths for each node in the cluster, install and configure STONITH.

Install the LifeKeeper STONITH script by running the following command:

/opt/LifeKeeper/samples/STONITH/stonith-install

#### 2. Edit the configuration file
Update the configuration file to enable STONITH and add the power off the command line. Note: Power off is recommended over reboot to avoid fence loops (i.e. two machines have lost communication but can still STONITH each other, taking turns powering each other off and rebooting).
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

The SIOS Protection Suite will protect the ASCS instance. The S4D_ASCS00 instance will have /usr/sap/S4D/ASCS00 data replication and IP Resource with Azure IP Gen App resource as a child.

### SIOS PORTS

GUI PORT 81 & 82
Remote Method Inovaction PORT 1024
Internode Communications 778 can be changed API_SSL_PORT in configuration variable /etc/default/LifeKeeper

LifeKeeper Data Replication
When using LifeKeeper Data Replication, the firewall should be configured to allow access to any of the ports used by nbd for replication.  The ports used by nbd can be calculated using the following formula:

10001 + \<mirror number\> + <256 * i>

where i starts at zero and is incremented until the formula calculates a port number that is not in use.  In use constitutes any port found defined in /etc/services, found in the output of netstat -an --inet, or already defined as in use by another LifeKeeper Data Replication resource.

For example: If the mirror number for the LifeKeeper Data Replication resource is 0, then the formula would initially calculate the port to use as 10001, but that number is defined in /etc/services on some Linux distributions as the SCP Configuration port.  In this case, i is incremented by 1 resulting in Port Number 10257, which is not in /etc/services on these Linux distributions.
