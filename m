From: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH cgroup/for-3.11 1/3] cgroup: mark "tasks" cgroup file as
	insane
Date: Tue, 4 Jun 2013 15:50:08 +0100
Message-ID: <20130604145008.GV4963@redhat.com>
References: <20130604021302.GH29989@mtj.dyndns.org>
	<20130604111556.GA4963@redhat.com>
	<20130604143444.GI4799@redhat.com>
Reply-To: "Daniel P. Berrange" <berrange-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20130604143444.GI4799-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, kay.sievers-tD+1rO4QERM@public.gmane.org, Michal Hocko <mhocko-AlSwsSmVLrQ@public.gmane.org>, lennart-mdGvqq1h2p+GdvJs77BJ7Q@public.gmane.org, Johannes Weiner <hannes-druUgvl0LCNAfugRpC6u6w@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Jun 04, 2013 at 10:34:44AM -0400, Vivek Goyal wrote:
> On Tue, Jun 04, 2013 at 12:15:56PM +0100, Daniel P. Berrange wrote:
> > On Mon, Jun 03, 2013 at 07:13:02PM -0700, Tejun Heo wrote:
> > > Some resources controlled by cgroup aren't per-task and cgroup core
> > > allowing threads of a single thread_group to be in different cgroups
> > > forced memcg do explicitly find the group leader and use it.  This is
> > > gonna be nasty when transitioning to unified hierarchy and in general
> > > we don't want and won't support granularity finer than processes.
> > 
> > With libvirt and KVM we require the ability to put different threads
> > in different cgroups for the "cpu", "cpuset" & "cpuacct" controllers.
> > This is to allow us to control schedular tunables / placement for
> > QEMU vCPU threads, independantly of limits for QEMU I/O threads. So
> > requiring all threads of a process to be in the same cgroup isn't
> > sufficiently flexible for our needs.
> 
> For placement of vCPU threads, can we set per thread cpu affinity
> (sched_setaffinity()), instead of using cgroups for that purpose.

sched_setaffinity can't overrride affinity already set in the
cgroup. So this won't allow for disjoint affinity sets between
threads. ie if you use cgroups to bind the process to pCPU 1
(to apply all possible non-vCPU threads) and then want to bind
vCPU threads to pCPU 2 you can't do it.

eg for cpu/cpuacct/cpuset controllers we have a setup

 <domain cgroup> 0 threads
   |
   +- vcpu0     1 thread
   +- vcpu1     1 thread
   +- emulator  n threads

and want complete independance in settings for each of these child
cgroups.

> Apart from cpu affinity, what scheduling parameters we want different
> between different threads.

Placement isn't the big deal - it is really the cpu.cfs_period_us,
cpu.cfs_quota_us and cpu.shares settings that are important ones,
along with cpuacct.{stat,usage,usage_percpu} to track utilization
across multiple threads.

For cpuacct, if we only had 1 cgroup for all threads, we'd have to
read the process's overall usage and then subtract usage of individual
threads. This would really be a step backwards, throwing away the
benefits that cgroups brought in allowing setup arbitrary grouping of
tasks :-(

Regards,
Daniel
-- 
|: http://berrange.com      -o-    http://www.flickr.com/photos/dberrange/ :|
|: http://libvirt.org              -o-             http://virt-manager.org :|
|: http://autobuild.org       -o-         http://search.cpan.org/~danberr/ :|
|: http://entangle-photo.org       -o-       http://live.gnome.org/gtk-vnc :|
