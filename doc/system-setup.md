# System Setup

Hardware and software characteristics of the system used.
```tex
• Host: NUC10i7FNK
• OS: Ubuntu 22.04.4 LTS x86 64
• Kernel: 5.19.1
• SGX Driver: Out-of-tree Driver (/dev/isgx)
• SGX Version: SGX1
• Secure boot: Enabled
• Full Disk encryption: LVM on LUKS
```

## Enhance Security
To add an extra layer of protection, since TEEs only provide encryption during application execution, we can enable `Full disk encryption` during OS installation.
Additionally, to ensure security guarantees regarding the kernel, we can enable `Secure Boot`.

## Steps

### • BIOS/UEFI setup
1. [Optional] Enable Secure Boot
2. Enable SGX

### • Install OS
1. Follow [this](https://ubuntu.com/tutorials/install-ubuntu-desktop#1-overview) guide, to install Ubuntu Desktop (Ubuntu Server can also be used similarly).
2. During the installation, enable "Secure Boot" and select LVM installation on LUKS.

### • Connectivity
1. Download and enable SSH to allow headless connection to the system.
```bash
sudo apt install openssh-server
sudo systemctl start ssh
sudo systemctl enable ssh
sudo ufw enable
sudo ufw allow ssh
```

### • Linux Kernel
Follow [this](https://phoenixnap.com/kb/build-linux-kernel), to build Kernel: `5.19.1` and install it in the system.
After experimentation, the in-kernel driver does not appear to work properly in this setup.

`IMPORTANT! DISABLE INTEL SGX module!`

### • [Optional] Create MOK to sign the new Kernel (since Secure Boot is enabled)
Read [this](https://ubuntu.com/blog/how-to-sign-things-for-secure-boot) and [this](https://github.com/berglh/ubuntu-sb-kernel-signing) for more information.

1. Install openssl and mokutil

2. Create a MOK
```bash
mkdir -p ~/Desktop/MOK-Kernel/
cd ~/Desktop/MOK-Kernel
openssl req -new -x509 -newkey rsa:2048 -keyout MOK.key -out MOK.crt -nodes -days 3650 -subj "/CN=Your Name/"
openssl x509 -in MOK.crt -out MOK.cer -outform DER
```

### • [Optional] Sign new Kernel using MOK (since Secure Boot is enabled)

1. Verify whether the system booted using Secure Boot.
```bash
sudo mokutil --sb-state
```

2. List the kernel images installed in /boot.
```bash
sudo ls -l /boot/vmlinuz*
```

3. Verify that the image isn’t already signed.
```bash
sudo sbverify --list /boot/vmlinuz-5.19.1
```

3. Download scripts for simplifing things [https://github.com/berglh/ubuntu-sb-kernel-signing](https://github.com/berglh/ubuntu-sb-kernel-signing)
```bash
cd ~/Desktop/MOK-Kernel
git clone https://github.com/berglh/ubuntu-sb-kernel-signing.git
cd ubuntu-sb-kernel-signing/sbin
sudo cp *.sh /usr/local/bin
cd ~/Desktop/MOK-Kernel
sudo bash mok-setup.sh # This will guide for everything
```

4. Now that MOK-Kernel exists under /var/lib/shim-signed/mok/, proceed with kernel signing.
```bash
sudo sbsign --key "/var/lib/shim-signed/mok/MOK-Kernel.priv" --cert "/var/lib/shim-signed/mok/MOK-Kernel.pem" --output "/boot/vmlinuz-5.19.1" "/boot/vmlinuz-5.19.1"
```

5. Verify the image is signed correctly
```bash
sudo sbverify --list /boot/vmlinuz-5.19.1
```

6. Make sure that Kernel `5.19.1` is selected by default on GRUB and then reboot.


### • SGX Out-of-tree driver
Follow [this](https://github.com/intel/linux-sgx-driver) guide to install the out of tree kernel driver ([instructions](https://download.01.org/intel-sgx/latest/linux-latest/docs/Intel_SGX_SW_Installation_Guide_for_Linux.pdf))

```bash
dpkg-query -s linux-headers-$(uname -r)
sudo apt-get install linux-headers-$(uname -r)
git clone https://github.com/intel/linux-sgx-driver
cd linux-sgx-driver/
make
sudo mkdir -p "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
sudo cp isgx.ko "/lib/modules/"`uname -r`"/kernel/drivers/intel/sgx"    
sudo sh -c "cat /etc/modules | grep -Fxq isgx || echo isgx >> /etc/modules"    
sudo /sbin/depmod
sudo /sbin/modprobe isgx # Need to sign first the driver (see below)
```

### • [Optional] Sign SGX Driver (since Secure Boot is enabled)
```bash
sudo kmodsign sha512 \
    /var/lib/shim-signed/mok/MOK-Kernel.priv \
    /var/lib/shim-signed/mok/MOK-Kernel.der \
    /usr/lib/modules/5.19.1/kernel/drivers/intel/sgx/isgx.ko
```

Now the system should be ready to be used.

