# Create SIOS Enhanced Azure IP Gen App Resource

  The application tag provided to be provided in the next screen is very important and the values are as follows

  1. Resource Group name in Azure

  2. The NIC name in Azure for the first node

  3. The IP address for the first node

  4. The NIC name in Azure for the second node

  5. The IP address for the second node

  6. The Virtual IP address to float between the 2 nodes.

  7. The adapter used, typically eth0.

  8. Name of the IP in Azure

![ ](/99_images/azure-ip-genapp-1.png)

![ ](/99_images/azure-ip-genapp-2.png)

![ ](/99_images/azure-ip-genapp-3.png)

![ ](/99_images/azure-ip-genapp-4.png)

![ ](/99_images/azure-ip-genapp-5.png)

![ ](/99_images/azure-ip-genapp-6.png)

![ ](/99_images/azure-ip-genapp-7.png)

![ ](/99_images/azure-ip-genapp-8.png)

![ ](/99_images/azure-ip-genapp-9.png)

![ ](/99_images/azure-ip-genapp-10.png)

![ ](/99_images/azure-ip-genapp-11.png)

![ ](/99_images/azure-ip-genapp-12.png)

![ ](/99_images/azure-ip-genapp-13.png)

![ ](/99_images/azure-ip-genapp-14.png)

![ ](/99_images/azure-ip-genapp-15.png)

![ ](/99_images/azure-ip-genapp-16.png)

![ ](/99_images/azure-ip-genapp-17.png)

![ ](/99_images/azure-ip-genapp-18.png)

![ ](/99_images/azure-ip-genapp-19.png)

![ ](/99_images/azure-ip-genapp-20.png)

![ ](/99_images/azure-ip-genapp-21.png)

![ ](/99_images/azure-ip-genapp-22.png)

  In Azure the ip will look as shown below

  ![ ](/99_images/image091.png "Secondary IP in portal.azure.com")

  In linux the secondary ip address will be added to the eth0 device

 ```bash
 ip add show
 ```

 ```console
 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
 link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
 inet 127.0.0.1/8 scope host lo
 valid_lft forever preferred_lft forever
 inet6 ::1/128 scope host
 valid_lft forever preferred_lft forever
 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
 link/ether 00:0d:3a:06:27:29 brd ff:ff:ff:ff:ff:ff
 inet 11.1.2.61/24 brd 11.1.2.255 scope global eth0
 valid_lft forever preferred_lft forever
 inet 11.1.2.60/24 scope global secondary eth0
 valid_lft forever preferred_lft forever
 inet6 fe80::20d:3aff:fe06:2729/64 scope link
 valid_lft forever preferred_lft forever
 ```