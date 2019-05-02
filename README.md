------------------DRAFT---------------------------------------

# High Availability Solution for SAP NetWeaver (RHEL, OEL & SuSE) & SAP HANA (RHEL & SuSE) on Azure using SIOS Protection Suite

## 1. Introduction

This document describes the procedure to implement High Availability Solution to protect SAP NW & SAP HANA on Azure using SIOS Protection Suite (SPS) for Linux. "SIOS Enhanced Azure Gen App" is used to switch IP address between cluster nodes instead using of Azure Internal Load Balancer.

please refer SAP Note [1662610](https://launchpad.support.sap.com/#/notes/1662610) Support details for SIOS Protection Suite for Linux

- Red Hat Enterprise Linux Server 7.4 (Maipo)

- SUSE Linux Enterprise Server 12 SP3

## 2. [SAP (A)SCS Cluster Configuration](HA-for-SAP-(A)SCS.md)

## 3. [SAP HANA Database Cluster Configuration](HA-for-SAP-HANA-DB.md)