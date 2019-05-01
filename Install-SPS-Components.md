# Install SIOS Protection Suite

### 1. Preparing Installation Media

 download the following media from the FTP link sent by SIOS

- download the SIOS protection Suite's - sps.img
- download the HANA Application Recovery Kit based on your HANA version - HANA2-ARK.run
- download the Azure IP Recovery kit - SIOS_enhancedAzure_gen_app-02.02.00.tgz
- file name might be different based on the version

### 2. Mount the Installation Media

 ```bash
 mkdir -p /DVD
 mount /sapmedia/SIOS931/sps.img /DVD -t iso9660 -o loop
 mount: /dev/loop0 is write-protected, mounting read-only
 ```

### 3. Setup SIOS Protection Suite -- Witness Nodes

 ```bash
  cd /DVD
  ./setup
 ```

 Please proceed with the installation steps as shown below
 ![ ](/99_images/image008.png)
 ![ ](/99_images/image009.png)
 ![ ](/99_images/image010.png)
 Please repeat the steps on the second witness node too.

### 4. Setup SIOS Protection Suite - SAP Recovery Kit

 Install SAP Recovery kit in ASCS and HANA Nodes
 change directory to SIOS installation media which was mounted as /DVD

```bash
 cd /DVD
 ./setup
 ```

 ![Select install License Key](/99_images/image011.png)*Select install License Key*

 ![Enter the license path & click ok](/99_images/image012.png)*Enter the license path & click ok*

 ![Select Recovery kit Selection Menu](/99_images/image013.png)*Select Recovery kit Selection Menu*

 ![Select Application Suite](/99_images/image014.png)*Select Application Suite*

 ![Select Lifekeeper SAP Recovery kit](/99_images/image015.png)*Select Lifekeeper SAP Recovery kit*

 ![Select Lifekeeper Startup after install & Select Done](/99_images/image016.png)*Select Lifekeeper Startup after install & Select Done*

 ![Select Yes & Press Enter](/99_images/image017.png)*Select Yes & Press Enter*
  
 ![ ](/99_images/image018.png)*Installation completed*

 ![ ](/99_images/image019.png)*license check message*

 Please repeat the steps on all cluster Nodes

### 5. Setup SIOS Enhanced Azure IP Gen Application

 You will receive the FTP link to download the tgz file.

- Use gunzip to unzip the tar file.
- Use command “tar -xvf” to untar the file
- Run the setup program
- NOTE: Make sure you put the files on a folder that is safe to execute. On some installations, programs need to be authorized to execute from certain folders. You can make sure  that the setup program has execute permission (chmod +x setup.)
- Repeat these steps on the other node.
- Note the folder where the files are stored (e.g. /root/folder