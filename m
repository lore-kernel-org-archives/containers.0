From: Fengguang Wu <fengguang.wu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [Lsf] [RFC] writeback and cgroup
Date: Mon, 16 Apr 2012 21:07:07 +0800
Message-ID: <20120416130707.GA10532__14459.7175335095$1334581969$gmane$org@localhost>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	<20120404145134.GC12676@redhat.com>
	<20120407080027.GA2584@quack.suse.cz>
	<20120410180653.GJ21801@redhat.com>
	<20120410210505.GE4936@quack.suse.cz>
	<20120410212041.GP21801@redhat.com>
	<20120410222425.GF4936@quack.suse.cz>
	<20120411154005.GD16692@redhat.com>
	<1334406314.2528.90.camel@twins>
	<20120416125432.GB12776@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20120416125432.GB12776-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: ctalbott-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, rni-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org, andrea-oIIqvOZpAevzfdHfmsDf5w@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, lsf-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, jmoyer-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Mon, Apr 16, 2012 at 08:54:32AM -0400, Vivek Goyal wrote:
> On Sat, Apr 14, 2012 at 02:25:14PM +0200, Peter Zijlstra wrote:
> > On Wed, 2012-04-11 at 11:40 -0400, Vivek Goyal wrote:
> > > 
> > > Ok, that's good to know. How would we configure this special bdi? I am
> > > assuming there is no backing device visible in /sys/block/<device>/queue/?
> > > Same is true for network file systems. 
> > 
> > root@twins:/usr/src/linux-2.6# awk '/nfs/ {print $3}' /proc/self/mountinfo | while read bdi ; do ls -la /sys/class/bdi/${bdi}/ ; done
> > ls: cannot access /sys/class/bdi/0:20/: No such file or directory
> > total 0
> > drwxr-xr-x  3 root root    0 2012-03-27 23:18 .
> > drwxr-xr-x 35 root root    0 2012-03-27 23:02 ..
> > -rw-r--r--  1 root root 4096 2012-04-14 14:22 max_ratio
> > -rw-r--r--  1 root root 4096 2012-04-14 14:22 min_ratio
> > drwxr-xr-x  2 root root    0 2012-04-14 14:22 power
> > -rw-r--r--  1 root root 4096 2012-04-14 14:22 read_ahead_kb
> > lrwxrwxrwx  1 root root    0 2012-03-27 23:18 subsystem -> ../../../../class/bdi
> > -rw-r--r--  1 root root 4096 2012-03-27 23:18 uevent
> 
> Ok, got it. So /proc/self/mountinfo has the information about st_dev and
> one can use that to reach to associated bdi. Thanks Peter.

Vivek, I noticed these lines in cfq code

                sscanf(dev_name(bdi->dev), "%u:%u", &major, &minor);

Why not use bdi->dev->devt?  The problem is that dev_name() will
return "btrfs-X" for btrfs rather than "major:minor".

Thanks,
Fengguang
