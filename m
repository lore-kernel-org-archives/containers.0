From: Nirmal Guhan <vavatutu-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: LXC bringup issue on Fedora
Date: Tue, 1 Jun 2010 22:09:48 -0700
Message-ID: <AANLkTilLWByODGTM23nKkAAlsDgON_pAUSFylsQ8Z3I-@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
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

Hi,

Am trying to get lenny (latest debian from http://ftp.us.debian.org/debian)
run as a container on Fedora12 with 2.6.32.13 kernel and running into below
error :

lxc-start -n lennycont
SELinux:  Could not open policy file <=
/etc/selinux/targeted/policy/policy.24:  No such file or directory
INIT: version 2.86 booting
INIT: Entering runlevel: 2
Starting enhanced syslogd: rsyslogd.
Starting periodic command scheduler: crond.

INIT: Id "4" respawning too fast: disabled for 5 minutes
INIT: Id "2" respawning too fast: disabled for 5 minutes
INIT: Id "T1" respawning too fast: disabled for 5 minutes
INIT: Id "1" respawning too fast: disabled for 5 minutes
INIT: Id "5" respawning too fast: disabled for 5 minutes
INIT: Id "3" respawning too fast: disabled for 5 minutes
INIT: Id "T0" respawning too fast: disabled for 5 minutes
INIT: Id "6" respawning too fast: disabled for 5 minutes
INIT: no more processes left in this runlevel

My config file is as below :

lxc.utsname = lennycont
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.ipv4 = 128.107.159.180/22
lxc.network.name = eth0
lxc.rootfs = /lxc/lenny-chroot
lxc.mount = /lxc/lenny.fstab
lxc.tty = 1

fstab :
none /lxc/lenny-chroot/dev/pts devpts defaults 0 0
none /lxc/lenny-chroot/proc    proc   defaults 0 0
none /lxc/lenny-chroot/sys     sysfs  defaults 0 0
none /lxc/lenny-chroot/dev/shm tmpfs  defaults 0 0

I googled and found some solutions but none of them worked for me :-( Could
you please help?

Thanks,
Nirmal
