# [Challenge 1](https://docs.google.com/document/d/1Zk_O_JpFQk5JQRGF9CAC0plml3ua3hCQ5VBDLxE2GQI/edit#) - Setup the lab automatically

Let’s create two machines, Machine A and Machine B.
- Machine A is the domain controller
- Domain Name is “auror.local”
- Has DNS role
- Create a user “Adam” with password “Pass@123”
- Machine B is the machine to join to domain auror.local
- Machine B should have Chrome installed
- User Adam is configured as an administrator
- Firewall should be off
- Machine A and Machine B must be in the same subnet. For example:
	- Machine A : 10.0.0.9
	- Machine B: 10.0.0.19
- You may use static IPs in your configuration

Test Cases:
- RDP into Machine B with user “Adam” should be successful
- From Machine B as user Adam, the command “net use \\auror.local” should result in
command completed successfully
- Run script Powerview.ps1 function “Get-DomainUser” from Machine B should show
Adam as a user
- Chrome should be installed on Machine B

## Overview

The automation within this repository builds out an Active Directory lab with Packer and Vagrant that was part of Challenge 1 of [The Auror Project](https://www.linkedin.com/feed/update/urn:li:activity:6919205808157155328/). The first step is to use Packer to build a Windows Server 2019 and Windows 10 base image. Then, a lab environment is created by Vagrant using the image output from Packer.


The lab consists of:
- DC1.auror.local: Domain Controller [Windows Server 2019](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-server-2019)
- PC01.auror.local: Member Workstation [Windows 10](https://www.microsoft.com/en-us/evalcenter/evaluate-windows-10-enterprise)


You may modify the included *Vagrantfile* to add or remove servers within the environment.

## Login credentials

As with all Vagrant boxes, the default credentials for the domain Administrator user are:

```
Username: vagrant
Password: vagrant
```

The default password complexity policy doesn't allow the password 'vagrant' so it is disabled.

> WARNING: Obviously this is a bad idea, but this is a test environment.

## VirtualBox

1. Download and install VirtualBox: https://www.virtualbox.org/wiki/Downloads

## Packer

### Install Packer

1. Download Packer: https://www.packer.io/
2. Extract the downloaded zip
3. Copy the *packer.exe* file to C:\Windows\System32\


### Build the base Windows Server 2019 image from an already downloaded ISO

1. Start Powershell as Administrator
2. Switch directory to the *server-2019* directory within the *Packer* directory
3. Copy the ISO files to the *Packer* directory
4. Run ```Get-FileHash -Algorithm SHA256 <Windows_Server_2019.iso>```
5. Modify the *server-server-2019.json* file to reflect the "iso_url" and "iso_checksum" as per the ISO to be used.
6. Run the base image build:

    ```
    packer build ./server-2019.json
    ```

The base image build can take a couple of minutes based on your host computer specifications. First, it will create a VM, install Server 2019, and then package the VM as a Vagrant box. The Windows Server 2019 box will be cached on the host computer so subsequent runs of the image build process will run much faster. This should create a file *server-2019.box* in the *Packer/Vagrant* folder.


### Build the base Windows 10 image from an already downloaded ISO

1. Start Powershell as Administrator
2. Switch directory to the *win10* directory within the *Packer* folder
3. Copy the ISO files to the *Packer* directory
4. Run ```Get-FileHash -Algorithm SHA256 <Windows_10.iso>```
5. Modify the *win10.json* file to reflect the "iso_url" and "iso_checksum" as per the ISO to be used.
6. Run the base image build:

    ```
    packer build ./win10.json
    ```

This will create a VM, install Windows 10, and then package the VM as a Vagrant box. The Windows 10 box will be cached on the host computer so subsequent runs of the image build process will run much faster. This should create a file *win10.box* in the *Packer/Vagrant* folder.


## Vagrant

1. Download and install Vagrant: https://www.vagrantup.com/downloads.html
2. Install Vagrant plugin for reboot Windows VMs:

    ```
    vagrant plugin install vagrant-reload
    ```

3. Install Vagrant plugin for automatically installing VirtualBox guest additions (drivers, supporting software, etc.):

    ```
    vagrant plugin install vagrant-vbguest
    ```

### Build the lab

1. Copy the packer provisioned *.box* files from the *Packer/Vagrant/* folder into the *Vagrant* folder
2. Open Powershell as an Administrator
3. Switch directory to the *Vagrant* directory
4. Build the lab:

    ```
    vagrant up
    ```

Building of the lab will take ~45 minutes, your mileage may vary, because VirtualBox needs to import the base boxes and prepare them to deploy with the specific scripts supplied. As per the challenge there were objectives set for each of the two machines being deployed.


### Other Vagrant commands

```
# Stop the lab
vagrant halt

# Start the lab
vagrant reload

# Destroy the lab
vagrant destroy
```

### Blog Post

Accompanying [blog post](https://macrosec.tech/index.php/2022/04/26/the-auror-project-challenge-1/) of the lab setup.

### References
https://github.com/eaksel?tab=repositories

https://github.com/jaredmmartin/Active-Directory-Lab

https://detectionlab.network/introduction/packerandvagrant/
