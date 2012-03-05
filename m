From: Mike Galbraith <efault-Mmb7MZpHnFY@public.gmane.org>
Subject: Re: [RFD] cgroup: about multiple hierarchies
Date: Mon, 05 Mar 2012 16:47:01 +0100
Message-ID: <1330962421.7368.69.camel__37238.4261027493$1330962444$gmane$org@marge.simpson.net>
References: <20120221211938.GE12236@google.com>
	<20120222163858.GB4128@redhat.com> <20120222165714.GC4128@redhat.com>
	<1329990094.24994.64.camel@twins> <1330006399.11248.20.camel@twins>
	<4F4FAF89.3090706@redhat.com>
	<1330633603.7414.49.camel@marge.simpson.net>
	<20120301210213.GF13533@redhat.com>
	<1330639448.7414.97.camel@marge.simpson.net>
	<20120305124310.GD10929@tango.0pointer.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20120305124310.GD10929-kS5D54t9nk0aINubkmmoJbNAH6kLmebB@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lennart Poettering <mzxreary-uLTowLwuiw4b1SvskN2V4Q@public.gmane.org>
Cc: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michal Schmidt <mschmidt-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Christoph Hellwig <hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, 2012-03-05 at 13:43 +0100, Lennart Poettering wrote: 
> On Thu, 01.03.12 23:04, Mike Galbraith (efault-Mmb7MZpHnFY@public.gmane.org) wrote:
> 
> > 
> > On Thu, 2012-03-01 at 16:02 -0500, Vivek Goyal wrote: 
> > > On Thu, Mar 01, 2012 at 09:26:43PM +0100, Mike Galbraith wrote:
> > 
> > > > Q: you say systemd requires CONFIG_CGROUPS=y.  Why is that?  It's taking
> > > > over sysvinits job afaiui, what does that have to do with cgroups?
> > > 
> > > I think they were using it to track all the children forked by a service
> > > and cleanup all of them if need be. So they just need it for logical
> > > grouping functionality and don't require any controllers as such.
> > 
> > Hm.  Controllers are perhaps not required, but cpu controller was
> > configured and used without consent.  I didn't receive an offer.
> 
> Just set DefaultControllers= in /etc/systemd/system.conf to an empty
> string and systemd will not make use of any hierarchy beyond its private
> name=systemd named hierarchy.

I updated my laptop to openSUSE 12.1 over the weekend, so tried it.  It
didn't work, so I tried setting JoinControllers= as well.  That split up
cpu and cpuacct, but didn't stop cpu from being used.  I then moved both
system.conf and user.conf to /etc/systemd/save, and got the original
setup back.. not surprising given everything was commented out in both
files to begin with.  The little bugger is stubborn.

maggy:/etc/systemd # mount|grep cgroup
tmpfs on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/ns type cgroup (rw,nosuid,nodev,noexec,relatime,ns)
cgroup on /sys/fs/cgroup/cpu type cgroup (rw,nosuid,nodev,noexec,relatime,cpu)
cgroup on /sys/fs/cgroup/cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpuacct)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
maggy:/etc/systemd # cat /sys/fs/cgroup/cpu/tasks|wc -l
262
maggy:/etc/systemd # cat system.conf
#  This file is part of systemd.
#
#  systemd is free software; you can redistribute it and/or modify it
#  under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
# See systemd.conf(5) for details

[Manager]
#LogLevel=info
#LogTarget=syslog-or-kmsg
#LogColor=yes
#LogLocation=no
#DumpCore=yes
#CrashShell=no
#ShowStatus=yes
#SysVConsole=yes
#CrashChVT=1
#CPUAffinity=1 2
#MountAuto=yes
#SwapAuto=yes
DefaultControllers=
#DefaultStandardOutput=syslog
#DefaultStandardError=inherit
JoinControllers=
maggy:/etc/systemd #

reboot...

maggy:/etc/systemd # mount|grep cgroup
tmpfs on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (rw,nosuid,nodev,noexec,relatime,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd)
cgroup on /sys/fs/cgroup/cpuset type cgroup (rw,nosuid,nodev,noexec,relatime,cpuset)
cgroup on /sys/fs/cgroup/ns type cgroup (rw,nosuid,nodev,noexec,relatime,ns)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (rw,nosuid,nodev,noexec,relatime,cpuacct,cpu)
cgroup on /sys/fs/cgroup/memory type cgroup (rw,nosuid,nodev,noexec,relatime,memory)
cgroup on /sys/fs/cgroup/devices type cgroup (rw,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/freezer type cgroup (rw,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/blkio type cgroup (rw,nosuid,nodev,noexec,relatime,blkio)
maggy:/etc/systemd # cat /sys/fs/cgroup/cpu/tasks|wc -l
146
maggy:/etc/systemd # ls
save  system  systemd-logind.conf  user
maggy:/etc/systemd #
