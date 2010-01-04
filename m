From: Dwight Schauer <dschauer-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: lxc-start: Device or resource busy - failed to remove previous
	cgroup
Date: Sun, 3 Jan 2010 19:46:29 -0600
Message-ID: <68e6eac61001031746r44668e6cheb497c7df5f68a18@mail.gmail.com>
References: <68e6eac61001031710w3e16f62blfb3b5bfb86ea43b7@mail.gmail.com>
	<661de9471001031722o21c6bd55kb73403c85a8145e3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <661de9471001031722o21c6bd55kb73403c85a8145e3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

On Sun, Jan 3, 2010 at 7:22 PM, Balbir Singh <bsingharora-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> Can you please paste the output of cat /proc/cgroups and cat /proc/mounts
Sure.

> This should not really happen, /proc/cgroups will help us figure out what
> is going on. As an alternative, if you can compile the debug cgroup container,
> you'll get a lot of useful debug information (CONFIG_CGROUP_DEBUG).

Yeah, I did not think that should happen.

Ok, here goes:

 $ sudo lxc-start -n arch64-1 /root/boot-init.sh
lxc-start: Device or resource busy - failed to remove previous cgroup
'/cgroup/arch64-1'
lxc-start: failed to spawn '/root/boot-init.sh'

$ sudo lxc-stop -n arch64-1
lxc-stop: container 'arch64-1' is not active

 $ cat /proc/cgroups
#subsys_name	hierarchy	num_cgroups	enabled
cpuset	127	7	1
ns	127	7	1
cpu	127	7	1
cpuacct	127	7	1
devices	127	7	1
freezer	127	7	1
net_cls	127	7	1

 $ cat /proc/mounts
rootfs / rootfs rw 0 0
none /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
none /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev tmpfs rw,relatime,size=10240k,mode=755 0 0
/dev/sda3 / jfs rw,noatime 0 0
tmpfs /lib/init/rw tmpfs rw,nosuid,relatime,mode=755 0 0
usbfs /proc/bus/usb usbfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev,relatime 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,mode=600,ptmxmode=000 0 0
/dev/sda1 /boot ext3 rw,noatime,errors=continue,data=ordered 0 0
/dev/sda9 /home jfs rw,noatime 0 0
/dev/sda6 /opt jfs rw,noatime 0 0
/dev/sda5 /tmp jfs rw,noatime 0 0
/dev/sda8 /usr jfs rw,noatime 0 0
/dev/sda7 /var jfs rw,noatime 0 0
/dev/sda9 /ve jfs rw,noatime 0 0
none /cgroup cgroup rw,noatime,net_cls,freezer,devices,cpuacct,cpu,ns,cpuset 0 0
/dev/sda9 /ve/lxc/rootfs/arch64-1/home/dwight/workspace jfs rw,noatime 0 0

 $ mount
/dev/sda3 on / type jfs (rw,noatime,errors=remount-ro)
tmpfs on /lib/init/rw type tmpfs (rw,nosuid,mode=0755)
proc on /proc type proc (rw,noexec,nosuid,nodev)
sysfs on /sys type sysfs (rw,noexec,nosuid,nodev)
procbususb on /proc/bus/usb type usbfs (rw)
udev on /dev type tmpfs (rw,mode=0755)
tmpfs on /dev/shm type tmpfs (rw,nosuid,nodev)
devpts on /dev/pts type devpts (rw,noexec,nosuid,gid=5,mode=620)
/dev/sda1 on /boot type ext3 (rw,noatime)
/dev/sda9 on /home type jfs (rw,noatime)
/dev/sda6 on /opt type jfs (rw,noatime)
/dev/sda5 on /tmp type jfs (rw,noatime)
/dev/sda8 on /usr type jfs (rw,noatime)
/dev/sda7 on /var type jfs (rw,noatime)
/home/ve on /ve type none (rw,bind,noatime)
none on /cgroup type cgroup (rw,noatime)
/home/dwight/workspace on
/ve/lxc/rootfs/arch64-1/home/dwight/workspace type none (rw,bind)

# I've been using bind mounts like that for a couple months now, no
problems there
# When it is in this state where I can't start arch64-1, I can start a
different container.

$ sudo screen lxc-start -n suzy111-640 /root/boot-init.sh
[detached]


 $ cat /proc/cgroups
#subsys_name	hierarchy	num_cgroups	enabled
cpuset	127	8	1
ns	127	8	1
cpu	127	8	1
cpuacct	127	8	1
devices	127	8	1
freezer	127	8	1
net_cls	127	8	1


$ cat /proc/mounts
rootfs / rootfs rw 0 0
none /sys sysfs rw,nosuid,nodev,noexec,relatime 0 0
none /proc proc rw,nosuid,nodev,noexec,relatime 0 0
udev /dev tmpfs rw,relatime,size=10240k,mode=755 0 0
/dev/sda3 / jfs rw,noatime 0 0
tmpfs /lib/init/rw tmpfs rw,nosuid,relatime,mode=755 0 0
usbfs /proc/bus/usb usbfs rw,nosuid,nodev,noexec,relatime 0 0
tmpfs /dev/shm tmpfs rw,nosuid,nodev,relatime 0 0
devpts /dev/pts devpts rw,nosuid,noexec,relatime,mode=600,ptmxmode=000 0 0
/dev/sda1 /boot ext3 rw,noatime,errors=continue,data=ordered 0 0
/dev/sda9 /home jfs rw,noatime 0 0
/dev/sda6 /opt jfs rw,noatime 0 0
/dev/sda5 /tmp jfs rw,noatime 0 0
/dev/sda8 /usr jfs rw,noatime 0 0
/dev/sda7 /var jfs rw,noatime 0 0
/dev/sda9 /ve jfs rw,noatime 0 0
none /cgroup cgroup rw,noatime,net_cls,freezer,devices,cpuacct,cpu,ns,cpuset 0 0
/dev/sda9 /ve/lxc/rootfs/arch64-1/home/dwight/workspace jfs rw,noatime 0 0


# OK, then I go and halt that container.
 $ sudo screen -R
[screen is terminating]

$ sudo lxc-info --name arch64-1
'arch64-1' is STOPPED
$ sudo lxc-info --name suzy111-640
'suzy111-640' is STOPPED

# OK, no running containers

 $ cat /proc/cgroups
#subsys_name	hierarchy	num_cgroups	enabled
cpuset	127	7	1
ns	127	7	1
cpu	127	7	1
cpuacct	127	7	1
devices	127	7	1
freezer	127	7	1
net_cls	127	7	1

That is all the information I have right now.
Dwight Schauer
