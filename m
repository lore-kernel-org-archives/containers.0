From: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Mon, 15 Mar 2010 10:16:21 -0400
Message-ID: <20100315141621.GD21127__2227.03153635866$1268662676$gmane$org@redhat.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311150307.GC29246@redhat.com> <20100311232708.GE2427@linux>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100311232708.GE2427@linux>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 12, 2010 at 12:27:09AM +0100, Andrea Righi wrote:
> On Thu, Mar 11, 2010 at 10:03:07AM -0500, Vivek Goyal wrote:
> > On Thu, Mar 11, 2010 at 06:25:00PM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Thu, 11 Mar 2010 10:14:25 +0100
> > > Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:
> > > 
> > > > On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > > > > On Thu, 11 Mar 2010 09:39:13 +0900
> > > > > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > > > > The performance overhead is not so huge in both solutions, but the impact on
> > > > > > > performance is even more reduced using a complicated solution...
> > > > > > > 
> > > > > > > Maybe we can go ahead with the simplest implementation for now and start to
> > > > > > > think to an alternative implementation of the page_cgroup locking and
> > > > > > > charge/uncharge of pages.
> > > > 
> > > > FWIW bit spinlocks suck massive.
> > > > 
> > > > > > 
> > > > > > maybe. But in this 2 years, one of our biggest concerns was the performance.
> > > > > > So, we do something complex in memcg. But complex-locking is , yes, complex.
> > > > > > Hmm..I don't want to bet we can fix locking scheme without something complex.
> > > > > > 
> > > > > But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
> > > > > will give us much benefit (of performance) than we lose by small overheads.
> > > > 
> > > > Well, the !cgroup or root case should really have no performance impact.
> > > > 
> > > > > IIUC, this series affects trgger for background-write-out.
> > > > 
> > > > Not sure though, while this does the accounting the actual writeout is
> > > > still !cgroup aware and can definately impact performance negatively by
> > > > shrinking too much.
> > > > 
> > > 
> > > Ah, okay, your point is !cgroup (ROOT cgroup case.)
> > > I don't think accounting these file cache status against root cgroup is necessary.
> > > 
> > 
> > I think what peter meant was that with memory cgroups created we will do
> > writeouts much more aggressively.
> > 
> > In balance_dirty_pages()
> > 
> > 	if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
> > 		break;
> > 
> > Now with Andrea's patches, we are calculating bdi_thres per memory cgroup
> > (almost)
> > 
> > bdi_thres ~= per_memory_cgroup_dirty * bdi_fraction
> > 
> > But bdi_nr_reclaimable and bdi_nr_writeback stats are still global.
> 
> Correct. More exactly:
> 
>  bdi_thresh = memcg dirty memory limit * BDI's share of the global dirty memory
> 
> Before:
> 
>  bdi_thresh = global dirty memory limit * BDI's share of the global dirty memory
> 
> > 
> > So for the same number of dirty pages system wide on this bdi, we will be
> > triggering writeouts much more aggressively if somebody has created few
> > memory cgroups and tasks are running in those cgroups.
> 
> Right, if we don't touch per-cgroup dirty limits.
> 
> > 
> > I guess it might cause performance regressions in case of small file
> > writeouts because previously one could have written the file to cache and
> > be done with it but with this patch set, there are higher changes that
> > you will be throttled to write the pages back to disk.
> > 
> > I guess we need two pieces to resolve this.
> > 	- BDI stats per cgroup.
> > 	- Writeback of inodes from same cgroup.
> > 
> > I think BDI stats per cgroup will increase the complextiy.
> 
> There'll be the opposite problem I think, the number of dirty pages
> (system-wide) will increase, because in this way we'll consider BDI
> shares of memcg dirty memory.

In the current form of patch, number of dirty pages system wide will not
increase. As following condition will be false more number of times and we
will be doing writeout more aggressively.

	if (bdi_nr_reclaimable + bdi_nr_writeback <= bdi_thresh)
			break;

Once we implement per cgroup per BDI stats for bdi_nr_reclaimable and
bdi_nr_writeback, then in theory we will have same number of dirty pages
in system as of today.

Thanks
Vivek

> So I think we need both: per memcg BDI
> stats and system-wide BDI stats, then we need to take the min of the two
> when evaluating bdi_thresh. Maybe... I'm not really sure about this, and
> need to figure better this part. So I started with the simplest
> implementation: global BDI stats, and per-memcg dirty memory.
> 
> I totally agree about the other point, writeback of inodes per cgroup is
> another feature that we need.
> 
> > I am still setting up the system to test whether we see any speedup in
> > writeout of large files with-in a memory cgroup with small memory limits.
> > I am assuming that we are expecting a speedup because we will start
> > writeouts early and background writeouts probably are faster than direct
> > reclaim?
> 
> mmh... speedup? I think with a large file write + reduced dirty limits
> you'll get a more uniform write-out (more frequent small writes),
> respect to few and less frequent large writes. The system will be more
> reactive, but I don't think you'll be able to see a speedup in the large
> write itself.
> 
> Thanks,
> -Andrea
