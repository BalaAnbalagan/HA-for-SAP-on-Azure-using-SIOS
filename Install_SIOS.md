## 6. SIOS Protection Suite 9.3.1
>
### 1. Preparation - Only for RHEL
>
#### 1. Disable SELinux (RHEL specific)
>SELinux is set to enforcing by default as shown below.
<pre><code>
# cat /etc/selinux/config

# This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
SELINUX=enforcing
# SELINUXTYPE= can take one of three two values:
# targeted - Targeted processes are protected,
# minimum - Modification of targeted policy. Only selected processes are protected.
# mls - Multi Level Security protection.
SELINUXTYPE=targeted
</code></pre>
> Please run the command below to change it to disabled
<pre><code>
sed -i 's/=enforcing/=disabled/' /etc/selinux/config`
</code></pre>
>check the SELinux is disabled
<pre><code>
 cat /etc/selinux/config
</code></pre>
```console
 # This file controls the state of SELinux on the system.
 # SELINUX= can take one of these three values:
 # enforcing - SELinux security policy is enforced.
 # permissive - SELinux prints warnings instead of enforcing.
 # disabled - No SELinux policy is loaded.
 SELINUX=disabled
 # SELINUXTYPE= can take one of three two values:
 # targeted - Targeted processes are protected,
 # minimum - Modification of targeted policy. Only selected processes are protected.
 # mls - Multi Level Security protection.
 SELINUXTYPE=targeted
```

#### 2. Reboot the VM
\* mandatory restart
><pre><code>
># reboot
></code></pre>


#### 3. Error for SELinux 

> If SELinux is not disabled, the installation will fail with the following error
>
> ![Error - SELinux Enabled](/99_images/image007.png)

 
<pre><code>
# cat /etc/selinux/config

This file controls the state of SELinux on the system.
# SELINUX= can take one of these three values:
# enforcing - SELinux security policy is enforced.
# permissive - SELinux prints warnings instead of enforcing.
# disabled - No SELinux policy is loaded.
SELINUX=disabled
# SELINUXTYPE= can take one of three two values:
# targeted - Targeted processes are protected,
# minimum - Modification of targeted policy. Only selected processes are protected.
# mls - Multi Level Security protection.
SELINUXTYPE=targeted
</code></pre>
 
#### 4. Preparing Installation Media
download the following media from the ftp link sent by SIOS
- download the SIOS protection Suite's - sps.img 
- download the HANA Application Recovery Kit based on your HANA version - HANA2-ARK.run 
- download the Azure IP Recovery kit - SIOS_enhancedAzure_gen_app-02.02.00.tgz
- file name might be different based on the version

#### 5. Mount the Installation Media
<pre><code>
mkdir -p /DVD
mount /sapmedia/SIOS931/sps.img /DVD -t iso9660 -o loop
mount: /dev/loop0 is write-protected, mounting read-only
</code></pre>

### 2. Setup SIOS Protection Suite -- Witness Nodes
--------------------------------------------

<pre><code>
cd /DVD
./setup
</code></pre>
> Please proceed with the installation steps as shown below
>
> ![](/99_images/image008.png)
>
> ![](/99_images/image009.png)
>
> ![](/99_images/image010.png)

> Please repeat the steps on the second witness node too.

### 3. Setup SIOS Protection Suite - SAP Recovery Kit 

[![SPS](https://www.youtube.com/watch?v=PMScbDAaEN8/0.jpg)](https://www.youtube.com/watch?v=arqv2YVp_3E)

> Install SAP Recovery kit in ASCS and HANA Nodes
change directory to SIOS installation media which was mounted as /DVD
</code></pre>
cd /DVD
./setup
</code></pre>
> ![Select install License Key](/99_images/image011.png)
>
>  *Select install License Key*

> ![Enter the license path & click ok](/99_images/image012.png)

>  *Enter the license path & click ok*
>
>  ![Select Recovery kit Selection Menu](/99_images/image013.png)*Select Recovery kit Selection Menu*

 

> ![Select Application Suite](/99_images/image014.png)*Select Application Suite*

\* *


> ![Select Lifekeeper SAP Recovery kit](/99_images/image015.png)*Select Lifekeeper SAP Recovery kit*

> ![Select Lifekeeper Startup after install & Select Done](/99_images/image016.png)*Select Lifekeeper Startup after install & Select Done*

> ![Select Yes & Press Enter](/99_images/image017.png)*Select Yes & Press Enter* 

> ![](/99_images/image018.png)
>*Installation completed*
>
> ![](/99_images/image019.png) 
>*license check message*

> Please repeat the steps on all cluster Nodes
