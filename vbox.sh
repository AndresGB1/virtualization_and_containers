#!/bin/bash

#CREATE VARIABLES
VMNAME="UBUNTU"
RAM="2048"
CPUS="2"
DISK="8000"
VIRTUALIZATION="/home/andresgb/Documentos/Andres/JalaSoft/Virtualization"
ISO="/home/andresgb/Descargas/ubuntu-22.04.1-desktop-amd64.iso"

#CREATE VIRTUAL MACHINE
#--register: register the virtual machine in the virtualbox
#grep -q: search for a pattern in a file
if ! VBoxManage list vms | grep -q $VMNAME; then
    VBoxManage createvm --name $VMNAME --ostype "Ubuntu_64" --register  --basefolder $VIRTUALIZATION/$VMNAME/MACHINE
fi

#--memory: set the memory size of the virtual machine.
#--acpi on means that the virtual machine will have ACPI support acpi means Advanced Configuration and Power Interface.
#--boot1 disk means that the virtual machine will boot from the first hard disk.
#--nic1 nat means that the virtual machine will have a network interface card (NIC) and will be connected to a network address translation (NAT) network nat means network address translation.
VBoxManage modifyvm $VMNAME --memory $RAM --acpi on --boot1 disk  --cpus $CPUS --nic1 nat 

#Show information of the virtual machine
#VBoxManage showvminfo $VMNAME

#Create a virtual hard disk
#createvdi creates a VDI disk image (VirtualBox Disk Image).
 if [ -f "$VIRTUALIZATION/$VMNAME/$VMNAME.vdi" ]; then
    #idk
    :
 else
    VBoxManage createvdi --filename $VIRTUALIZATION/$VMNAME/$VMNAME.vdi --size $DISK
fi

#VBoxManage: attach the virtual ssd hard disk to the virtual machine.
if ! VBoxManage showvminfo $VMNAME | grep -q "SATA Controller"; then
#--storagectl: add a new storage controller to the virtual machine.
     VBoxManage storagectl $VMNAME --name "SATA Controller" --add sata
fi
#--port: set the port number of the storage device.
#--device: set the device number of the storage device.
#--type: set the type of the storage device.
VBoxManage storageattach $VMNAME --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VIRTUALIZATION/$VMNAME/$VMNAME.vdi

#ISO: add the iso file to the virtual machine.
if ! VBoxManage showvminfo $VMNAME | grep -q "IDE Controller"; then
     VBoxManage storagectl $VMNAME --name "IDE Controller" --add ide
fi
VBoxManage storageattach $VMNAME  --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium $ISO

#VBoxManage: start the virtual machine.
VBoxManage startvm $VMNAME

