From: Kay Sievers <kay.sievers-tD+1rO4QERM@public.gmane.org>
Subject: Re: [PATCH] cgroupfs: create /sys/fs/cgroup to mount cgroupfs on
Date: Fri, 23 Jul 2010 01:23:01 +0200
Message-ID: <1279840981.2036.4.camel__1322.64723438329$1279841091$gmane$org@yio.site>
References: <20100722182638.GA12712@kroah.com>
	<AANLkTinRGBksuWAZhdmvr39FNACU18+kc5ut49VUf=mp@mail.gmail.com>
	<20100722183614.GA5443@suse.de> <20100722193741.GA2688@redhat.com>
	<20100722211856.GA1297@suse.de>
	<AANLkTinFQtwrCC82T9KlKskDV8fn-zYgimyH2wguHkqY@mail.gmail.com>
	<20100722231401.GA11538@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100722231401.GA11538-l3A5Bk7waGM@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org>
Cc: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Li-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Jan Safranek <jsafrane-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Lennart Poettering <lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 2010-07-22 at 16:14 -0700, Greg KH wrote:
> On Fri, Jul 23, 2010 at 01:08:12AM +0200, Kay Sievers wrote:
> > On Thu, Jul 22, 2010 at 23:18, Greg KH <gregkh-l3A5Bk7waGM@public.gmane.org> wrote:
> > >> For my testing I now always use /cgroup/ and create directories under it
> > >> /cgroup/blkio /cgroup/cpu etc and mount controllers on respective
> > >> directories.
> > >
> > > Lennart and Kay, is this what systemd is doing?  I really don't think we
> > > should be adding a root /cgroup/ mount point to the system for something
> > > like this.
> > 
> > Already solved. Systemd always mounts an empty tmpfs at the 'cgroup'
> > mountpoint, and stuff is free to create subdirs there. Systemd itself
> > mount 'systemd' there.
> 
> Ah, that makes it easier.  Paul and Vivek, any objection to this patch
> going in now?

Just to get an idea, here is the current output on a systemd system:

/dev/sda3 /home/kay/work ext3 rw,noatime,errors=continue,user_xattr,acl,barrier=0,data=writeback 0 0
devtmpfs /dev devtmpfs rw,relatime,size=1965252k,nr_inodes=491313,mode=755 0 0
proc /proc proc rw,relatime 0 0
sysfs /sys sysfs rw,relatime 0 0
tmpfs /dev/shm tmpfs rw,relatime 0 0
devpts /dev/pts devpts rw,relatime,mode=600 0 0
tmpfs /cgroup tmpfs rw,nosuid,nodev,noexec,relatime,mode=755 0 0
cgroup /cgroup/systemd cgroup rw,nosuid,nodev,noexec,relatime,release_agent=/lib/systemd/systemd-cgroups-agent,name=systemd 0 0
systemd-1 /dev/mqueue autofs rw,relatime,fd=15,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
systemd-1 /sys/kernel/security autofs rw,relatime,fd=16,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
systemd-1 /proc/sys/fs/binfmt_misc autofs rw,relatime,fd=17,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
systemd-1 /sys/kernel/debug autofs rw,relatime,fd=18,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
systemd-1 /dev/hugepages autofs rw,relatime,fd=19,pgrp=1,timeout=300,minproto=5,maxproto=5,direct 0 0
tmpfs /var/run tmpfs rw,relatime,mode=755 0 0
tmpfs /var/lock tmpfs rw,relatime,mode=775,gid=54 0 0
fusectl /sys/fs/fuse/connections fusectl rw,relatime 0 0
gvfs-fuse-daemon /home/kay/.gvfs fuse.gvfs-fuse-daemon rw,nosuid,nodev,relatime,user_id=2702,group_id=100 0 0

Kay
