# Switch VIP to Node 2

NODE :1

```bash
ip addr show
```

```console
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0d:3a:06:27:29NODE brd ff:ff:ff:ff:ff:ff
    inet 11.1.2.61/24 brd 11.1.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 11.1.2.60/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20d:3aff:fe06:2729/64 scope link
       valid_lft forever preferred_lft
```

![ ](/99_images/SWITCH-IP-1.png)

![ ](/99_images/SWITCH-IP-2.png)

![ ](/99_images/SWITCH-IP-3.png)

![ ](/99_images/SWITCH-IP-4.png)

![ ](/99_images/SWITCH-IP-5.png)

![ ](/99_images/SWITCH-IP-6.png)

![ ](/99_images/SWITCH-IP-7.png)

![ ](/99_images/SWITCH-IP-8.png)

![ ](/99_images/SWITCH-IP-9.png)

![ ](/99_images/SWITCH-IP-10.png)

NODE-2

```bash
ip addr show
```

```console
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:0d:3a:07:03:7f brd ff:ff:ff:ff:ff:ff
    inet 11.1.2.62/24 brd 11.1.2.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet 11.1.2.60/24 scope global secondary eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::20d:3aff:fe07:37f/64 scope link
       valid_lft forever preferred_lft forever
```

![ ](/99_images/SWITCH-IP-11.png)

![ ](/99_images/SWITCH-IP-12.png)