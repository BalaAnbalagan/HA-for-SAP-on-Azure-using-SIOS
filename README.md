
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





## 2. [SIOS Protection Suite for Linux Overview](SIOS_Overview.md)
## 3. [Infrastructure Design](SIOS_Infrastructure_Design.md)
## 4. [Infrastructure Provisioning](https://github.com/BalaAnbalagan/SAP-on-Azure-using-Terraform)
## 5. [Azure CLI Installation for Linux](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-apt?view=azure-cli-latest)
## 6. [Install SIOS Protection Suite 9.3.1](Install_SIOS.md)
## 7. [SAP HANA Database Cluster Configuration](HA-for-SAP-HANA-DB.md)
## 8. [SAP A(SCS) Cluster Configuration](HA-for-SAP-(A)SCS.md)
## 9. [SAP Failover Testing](SIOS-Failover-Testing.md)