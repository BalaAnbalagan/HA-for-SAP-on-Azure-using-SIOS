mkdir /home/cloud-user/install
chown -R cloud-user:cloud-user /home/cloud-user/install

HANA_LOG_FILE=/home/cloud-user/install/install.log
log() {
    echo `date` $* 2>&1 | tee -a $HANA_LOG_FILE
}

exec 3>&1 1>>/home/cloud-user/install/ascs.log 2>&1 

#log change hostnames
#hostname ${lower(hostname)}
#echo ${lower(hostname)} > /etc/hostname
#echo HOSTNAME=${lower(hostname)}.provingground.net >> /etc/sysconfig/network
#echo "preserve_hostname: true" >> /etc/cloud/cloud.cfg

log update dns server
# set the dns server to provingground.net
sed -i 's/reddog.microsoft.com/provingground.net/' /etc/resolv.conf

log set timezone to Americas/New_York
# set timezone to America/Los_Angeles regardless of AZ
timedatectl set-timezone America/Los_Angeles

log software remove, update, install
zypper -n install bzip2 iproute iputils mktemp patch  compat-sap-c++-6 libtool-ltdl nfs-utils nfs-utils-lib
# redhat-lsb

#FS layout 

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

# DISK 2 /usr/sap/<SID>

while [ ! -e /dev/sdd ] ; do
log waiting for sdd
sleep 10;
done;

log creating /usr/data mount
mkdir -p /usr/sap/S4D
parted /dev/sdd unit GB
parted /dev/sdd mklabel gpt
parted /dev/sdd mkpart primary 0% 100%
log partitioning /usr/sap/S4D

while [ ! -e /dev/sdd1 ] ; do
log waiting for sdd1
sleep 10;
done;

mkfs.xfs /dev/sdd1
mount /dev/sdd1 /usr/sap/S4D
echo "/dev/sdd1  /usr/sap/S4D  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /usr/sap/S4D

# DISK 3 /usr/sap/<SID>/ASCS00

while [ ! -e /dev/sde ] ; do
log waiting for sde
sleep 10;
done;

log creating /usr/data mount
mkdir -p /usr/sap/S4D/ASCS00
parted /dev/sde unit GB
parted /dev/sde mklabel gpt
parted /dev/sde mkpart primary 0% 100%
log partitioning /usr/sap/S4D/ASCS00

while [ ! -e /dev/sde1 ] ; do
log waiting for sde1
sleep 10;
done;

mkfs.xfs /dev/sde1
mount /dev/sde1 /usr/sap/S4D/ASCS00
echo "/dev/sde1  /usr/sap/S4D/ASCS00  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /usr/sap/S4D/ASCS00


# DISK 4 /usr/sap/<SID>/ERS10

while [ ! -e /dev/sdf ] ; do
log waiting for sdf
sleep 10;
done;

log creating /usr/data mount
mkdir -p /usr/sap/S4D/ERS00
parted /dev/sdf unit GB
parted /dev/sdf mklabel gpt
parted /dev/sdf mkpart primary 0% 100%
log partitioning /usr/sap/S4D/ERS00

while [ ! -e /dev/sdf1 ] ; do
log waiting for sdf1
sleep 10;
done;

mkfs.xfs /dev/sdf1
mount /dev/sdf1 /usr/sap/S4D/ERS00
echo "/dev/sdf1  /usr/sap/S4D/ERS00  xfs  defaults  0   0" >> /etc/fstab
log formatted and mounted /usr/sap/S4D/ERS00
# NFS Mounts

log mounting nfs
mkdir /sapmedia
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:export/media /sapmedia
echo "pg-nfs01.provingground.net:/export/media  /sapmedia  nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab
mkdir /sapmnt
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:/export/media/sapmnt /sapmnt
echo "pg-nfs01.provingground.net:/export/media/sapmnt  /sapmnt nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab

mkdir /usr/sap/trans
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 pg-nfs01.provingground.net:/export/media/saptrans /usr/sap/trans
echo "pg-nfs01.provingground.net:/export/media/saptrans  /usr/sap/trans nfs4  nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2" >> /etc/fstab

log restarting crond and rsyslog to fix time zone
systemctl restart cron.service
systemctl restart rsyslog
#restart network to update dhcp
systemctl restart network

log END post-install cleanup