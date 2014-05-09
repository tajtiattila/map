
Ubuntu server with Docker for Virtualbox
========================================

Initial virtualbox setup
------------------------

Download the ISO file for Ubuntu Server 12.04 LTS (64-bit).

Set up a VM with 512M memory, a large dynamic HDD (several, eg. 128 gigabyres
for Docker containers) and no remote display.

Use bridged network adapter (so that the VM and possibly the
Docker containers within can be accessed easily from the outside).

Finally add a shared folder, and start up the VM.

Add the following to the kernel command line (ESC then F6 at the boot screen)

	priority=critical locale=en_US url=http://HOSTIP:8181/uinstall

Configure guest
---------------

Log in with:

- user: docker
- password: ubuntu

Add your ssh public key to `$HOME/.ssh/authorized_keys` to connect to it via
ssh easily.

Edit the sudoers file with

	sudo visudo

and add the line:

	docker ALL=NOPASSWD: ALL

at the very end of the file (otherwise it may be overwritten by other rules),
if you do not want to enter your password for sudo time to time.

Install docker
--------------

Follow the installation instructions from docker.io.

Install virtualbox guest additions
----------------------------------

To be able to access the shared folder from Linux, mount the
VBoxGuestAdditions.iso that came with Virtualbox, and follow the
instructions.

	cd /media/cdrom
	sudo ./VBoxLinuxAdditions.run

If the link to mount.vboxsf is invalid (mount -t vboxsf reports invalid
filesystem) then try to fix it with:

	sudo rm /sbin/mount.vboxsf
	sudo ln -s /usr/lib/x86_64-linux-gnu/VBoxGuestAdditions /sbin/mount.vboxsf

