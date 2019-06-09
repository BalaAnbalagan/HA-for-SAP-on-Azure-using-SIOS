# High availability for NFS on Linux Azure VMs using SIOS

This article describes how to deploy the virtual machines, configure the virtual machines, install the cluster framework, and install a highly available NFS server that can be used to store the shared data of a highly available SAP system. This guide describes how to set up a highly available NFS server that is used by two SAP systems, pg-nfs1 and pg-nfs2. The names of the resources (for example virtual machines, virtual networks) in the example assume that you have used the SAP file server template with resource prefix prod.

Read the following SAP Notes and papers first

SAP Note 1928533, which has:

- List of Azure VM sizes that are supported for the deployment of SAP software
- Important capacity information for Azure VM sizes
- Supported SAP software, and operating system (OS) and database combinations
- Required SAP kernel version for Windows and Linux on Microsoft Azure

SAP Note 2015553 lists prerequisites for SAP-supported SAP software deployments in Azure.

SAP Note 2205917 has recommended OS settings for SUSE Linux Enterprise Server for SAP Applications

SAP Note 1944799 has SAP HANA Guidelines for SUSE Linux Enterprise Server for SAP Applications

SAP Note 2178632 has detailed information about all monitoring metrics reported for SAP in Azure.

SAP Note 2191498 has the required SAP Host Agent version for Linux in Azure.

SAP Note 2243692 has information about SAP licensing on Linux in Azure.

SAP Note 1984787 has general information about SUSE Linux Enterprise Server 12.

SAP Note 1999351 has additional troubleshooting information for the Azure Enhanced Monitoring Extension for SAP.

SAP Community WIKI has all required SAP Notes for Linux.

Azure Virtual Machines planning and implementation for SAP on Linux

Azure Virtual Machines deployment for SAP on Linux (this article)

Azure Virtual Machines DBMS deployment for SAP on Linux

SUSE Linux Enterprise High Availability Extension 12 SP3 best practices guides

Highly Available NFS Storage with DRBD and Pacemaker
SUSE Linux Enterprise Server for SAP Applications 12 SP3 best practices guides

SUSE High Availability Extension 12 SP3 Release Notes
Overview
To achieve high availability, SAP NetWeaver requires an NFS server. The NFS server is configured in a separate cluster and can be used by multiple SAP systems.



The NFS server uses a dedicated virtual hostname and virtual IP addresses for every SAP system that uses this NFS server. On Azure, a load balancer is required to use a virtual IP address. The following list shows the configuration of the load balancer.

Frontend configuration

- IP address 11.1.1.11 for pg-nf1
- IP address 11.1.1.12 for pg-nf2

Backend configuration

- Connected to primary network interfaces of all virtual machines that should be part of the NFS cluster

Probe Port

- Port 61000 for pg-nf1
- Port 61001 for pg-nf2

Loadbalancing rules

- 2049 TCP for pg-nf1
- 2049 UDP for pg-nf1
- 2049 TCP for pg-nf2
- 2049 UDP for pg-nf2
