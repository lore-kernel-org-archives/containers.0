From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: trying to build simple checkpoint/restart recipes
Date: Wed, 8 Dec 2010 04:53:22 +0000
Message-ID: <20101208045322.GA17602@mail.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

What I've done so far:

	created a KVM vm and installed up-to-date maverick
	add-apt-repository ppa:appcr/ppa
	apt-get update && apt-get dist-upgrade
	apt-get install libvirt-bin lxc linux-image-2.6.34-1cr4
	sed -i 's/GRUB_DEFAULT=0/GRUB_DEFAULT="Ubuntu, with Linux 2.6.34-1cr4-generic"/' /etc/default/grub
	update-grub

	replaced 122 with 123 in /etc/libvirt/qemu/networks/default.xml and /var/lib/libvirt/network/default.xml
	reboot

	# The following should go into an upstart script shipped with the appcr packages
	# as they must be done on each boot
	chmod 666 /dev/pts/ptmx
	rm /dev/ptmx
	ln -s /dev/pts/ptmx /dev/ptmx
	mkdir -p /cgroup
	mount -t cgroup cggroup /cgroup/
	echo /bin/remove_dead_cgroup.sh > /cgroup/release_agent
	echo 1 > /cgroup/notify_on_release
	#

	cat > /etc/lxc-basic.conf << EOF
	lxc.network.type=veth
	lxc.network.link=virbr0
	lxc.network.flags=up
	EOF

	lxc-create -f /etc/lxc-basic.conf -n cr1 -t ubuntu
	cd /var/lib/lxc/cr1/rootfs/sbin
	mv init upstart

	cat > init << EOF
	#!/bin/sh
	rm -f /shutdown
	hostname cr1

	exec 0<&-
	exec 0</dev/null
	exec 1>&-
	exec 1>nohup.out
	exec 2>&-
	exec 2>nohup.out

	mkdir -p /tmp2
	mount --bind /tmp2 /tmp

	mount -a
	mount -t proc proc /proc
	mount -t tmpfs varrun /var/run
	mkdir /var/run/network
	mkdir /var/run/sshd
	ifconfig eth0 192.168.123.21 up
	screen -A -d -m -S console

	/usr/sbin/sshd
	while [ ! -f /shutdown ]; do
		  sleep 4s
	done
	EOF

	lxc-start -n cr1

	(in another console)
	ssh 192.168.123.21
	  screen -r
	  ps
	  ctrl-a d
	exit

	lxc-freeze -n cr1
	lxc-checkout -n cr1 -S /root/cr1.s1

So far, so good.  Note that I couldn't use upstart for my init bc upstart
uses inotify, which we don't yet checkpoint.  The kernel is compiled without
ipv6 bc that was also causing a problem (though I thought ipv6 was supported
for checkpoint?) and therefore I needed a custom libvirt package which didn't
break when ipv6 is not there.

The problem now is when attempting to restart:

	lxc-stop -n cr1
	lxc-restart -n cr1 -S /root/cr1.s1

There are two issues:

1. how to re-create the mounts.  Kernel doesn't do it yet.  There
   isn't (that I know of) a clean way to hook lxc-restart to do it.
   Comments?

2. likewise there *may* end up being a question of where to best hook
   the backup/snapshot and restore of filesystems.  Though for these
   examples (screen and next vncserver) it shouldn't be necessary.

I'm trying to do this using lxc-checkpoint and lxc-restart so as to
keep the instructions as simple as possible.  The hope is in the next
few weeks to have a few recipes that people can try out.  But if it's
not (cleanly) possible using lxc-restart, then I guess I can switch to
using user-cr and some container tarballs, which seems a lot easier in
the short term but less useful in the long term.

thanks,
-serge
