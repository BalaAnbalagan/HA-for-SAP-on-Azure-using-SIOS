#!/bin/bash

mkdir /home/cloud-user/install
chown -R cloud-user:cloud-user /home/cloud-user/install

HANA_LOG_FILE=/home/cloud-user/install/install.log
log() {
    echo `date` $* 2>&1 | tee -a $HANA_LOG_FILE
}

exec 3>&1 1>>/home/cloud-user/install/misc.log 2>&1 

log update dns server
# set the dns server to provingground.net
sed -i 's/reddog.microsoft.com/provingground.net/' /etc/resolv.conf


# log change hostnames
# hostname ${lower(hostname)}
# echo ${lower(hostname)} > /etc/hostname
# echo HOSTNAME=${lower(hostname)}.${domain_name} >> /etc/sysconfig/network
# echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

log set timezone to Americas/New_York
# set timezone to America/Los_Angeles regardless of AZ
timedatectl set-timezone America/Los_Angeles

log software remove, update, install
#yum -y install bzip2 iproute iputils mktemp patch redhat-lsb compat-sap-c++-6 libtool-ltdl nfs-utils nfs-utils-lib
zypper -n install bzip2 iproute iputils mktemp patch lsb compat-sap-c++-6 libtool-ltdl nfs-utils nfs-utils-lib x11-tools


#FS layout 
# DISK 1 /usr/sap/

while [ ! -e /dev/sdc ] ; do
log waiting for sdc
sleep 10;
done;

log creating /usr/sap mount
mkdir -p /usr/sap
parted /dev/sdc unit GB
parted /dev/sdc mklabel gpt
parted /dev/sdc mkpart primary 0% 100%
log partitioning /usr/sap

while [ ! -e /dev/sdc1 ] ; do
log waiting for sdc1
sleep 10;
done;

mkfs.xfs /dev/sdc1
mount /dev/sdc1 /usr/sap
echo "/dev/sdc1  /usr/sap  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /usr/sap

# DISK 2 /hana/data

while [ ! -e /dev/sde ] ; do
log waiting for sde
sleep 10;
done;

log creating /hana/data mount
mkdir -p /hana/data
parted /dev/sde unit TB
parted /dev/sde mklabel gpt
parted /dev/sde mkpart primary 0% 100%
log partitioning /hana/data

while [ ! -e /dev/sde1 ] ; do
log waiting for sde1
sleep 10;
done;

mkfs.xfs /dev/sde1
mount /dev/sde1 /hana/data
echo "/dev/sde1  /hana/data  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /hana/data

# DISK 3 /hana/shared
while [ ! -e /dev/sdf ] ; do
log waiting for sdf
sleep 10;
done;

log creating /hana/shared/
mkdir -p /hana/shared/
parted /dev/sdf unit TB
parted /dev/sdf mklabel gpt
parted /dev/sdf mkpart primary 0% 100%
log partitioning /hana/shared/

while [ ! -e /dev/sdf1 ] ; do
log waiting for sdf1
sleep 10;
done;

mkfs.xfs /dev/sdf1
mount /dev/sdf1 /hana/shared/
echo "/dev/sdf1  /hana/shared/  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /hana/shared/


# DISK 4 /hana/log
while [ ! -e /dev/sdg ] ; do
log waiting for sdg
sleep 10;
done;




log creating /hana/log mount
mkdir -p /hana/log
parted /dev/sdg unit TB
parted /dev/sdg mklabel gpt
parted /dev/sdg mkpart primary 0% 100%
log partitioning /hana/log

while [ ! -e /dev/sdg1 ] ; do
log waiting for sdg1
sleep 10;
done;

mkfs.xfs /dev/sdg1
mount /dev/sdg1 /hana/log
echo "/dev/sdg1  /hana/log  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /hana/log

# DISK 5 /hana/log
while [ ! -e /dev/sdd ] ; do
log waiting for sdd
sleep 10;
done;




log creating /backup mount
mkdir -p /backup
parted /dev/sdd unit TB
parted /dev/sdd mklabel gpt
parted /dev/sdd mkpart primary 0% 100%
log partitioning /backup

while [ ! -e /dev/sdd1 ] ; do
log waiting for sdd1
sleep 10;
done;

mkfs.xfs /dev/sdd1
mount /dev/sdd1 /backup
echo "/dev/sdd1  /backup  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /backup

############

log mounting nfs
mkdir /sapmedia
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:export/media /sapmedia
echo "pg-nfs01.provingground.net:/export/media  /sapmedia  nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab

#mkdir /sapmnt
#mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:/export/media/sapmnt /sapmnt
#echo "pg-nfs01.provingground.net:/export/media/sapmnt  /sapmnt nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab

#mkdir /usr/sap/trans
#mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:/export/media/saptrans /usr/sap/trans
#echo "pg-nfs01.provingground.net:/export/media/saptrans  /usr/sap/trans nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab

log restarting crond and rsyslog to fix time zone
systemctl restart cron.service
systemctl restart rsyslog
#restart network to update dhcp
systemctl restart network

log END post-install cleanup

