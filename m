From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Fri, 7 Jun 2013 11:12:20 +0100
Message-ID: <20130607101220.GE10742@redhat.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604201947.GE14916@htj.dyndns.org>
	<20130606092055.GF30217@redhat.com>
	<20130606211410.GF5045@htj.dyndns.org>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130606211410.GF5045-Gd/HAXX7CRxy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, Jun 06, 2013 at 02:14:10PM -0700, Tejun Heo wrote:
> Hello,
> 
> On Thu, Jun 06, 2013 at 10:20:55AM +0100, Daniel P. Berrange wrote:
> > Unless I'm mistaken there is no alternative that can work. With QEMU
> > we need to apply scheduling controls to 
> > 
> >   1. Individual vCPU threads
> >   2. All non-vCPU threads (ie QEMU's I/O threads)
> > 
> > We can use per-thread APIs for 1, but for 2 we require something that
> > applies to the group of threads as a whole, without also impacting the
> > controls set for the vCPU threads. AFAIK, nothing except cgroups as
> > we use them today can satisfy that requirement ? Am I wrong ? Is there
> > something else that can achieve this same setup ?
> 
> Can you please explain more about your requirements on !vCPU threads?

Well we pretty much needs the tunables available in the cpu, cpuset
and cpuacct controllers to be available for the set of non-vCPU threads
as a group. eg, cpu_shares, cfs_period_us, cfs_quota_us, cpuacct.usage,
cpuacct.usage_percpu, cpuset.cpus, cpuset.mems.

CPU/memory affinity could possibly be done with a combination of
sched_setaffinity + libnuma, but I'm not sure that it has quite
the same semantics. IIUC, with cpuset cgroup changing affinity
will cause the kernel to migrate existing memory allocations to
the newly specified node masks, but this isn't done if you just
use sched_setaffinity/libnuma.

For cpu accounting, you'd have to look at the overall cgroup usage
and then subtract the usage accounted to each vcpu thread to get
the non-vCPU thread group total. Possible but slightly tedious &
more inaccurate since you will have timing delays getting info
from each thread's /proc files

I don't see any way to do cpu_sahres, cfs_period_us and cfs_quota_us
for the group of non-vCPU threads as a whole. You can't set these
at the per-thread level since that is semantically very different.
You can't set these for the process as a whole at the cgroup level,
since that'll confine vCPU threads at the same time which is also
semantically very different.

We need completely separate scheduler tuning for the set of non-vCPU
threads, vs each vCPU thread. AFAICT the only way todo this is with
cgroups, grouping together subsets of threads within the process.

> > I understand that having wildly distinct hiearchies across different
> > controllers causes alot of pain for the kernel. Libvirt doesn't
> > actually require that full level of flexibility though. Our needs
> > are very much simpler. We're happy with the same core hierarchy
> > across all controllers. We just want to be able to create an extra
> > leaf node in some controllers to move threads about. 
> > 
> > It would be fine with us if the kernel required that the same directory
> > hierarchy exists in all controllers, and mandated that threads can only
> > be moved to a directory immediately below where the process is initially
> > placed.
> 
> The problem is that it doesn't make any sense to split threads of the
> same process for at least two major controllers and you end up with
> situation where you can't identify a resource to be belonging to a
> certain cgroup because such level of granularity is simply undefined.
> As I wrote before, we can special case certain controllers but I'm
> extremely reluctant.  If you need it, please convince me.

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
