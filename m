From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Wed, 17 Mar 2010 23:32:22 +0100
Message-ID: <20100317223222.GA8467__44780.0437840216$1268865332$gmane$org@linux.develer.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311150307.GC29246@redhat.com>
	<20100312084230.850f331d.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315143841.GE21127@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100315143841.GE21127-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Mon, Mar 15, 2010 at 10:38:41AM -0400, Vivek Goyal wrote:
> > > 
> > > bdi_thres ~= per_memory_cgroup_dirty * bdi_fraction
> > > 
> > > But bdi_nr_reclaimable and bdi_nr_writeback stats are still global.
> > > 
> > Why bdi_thresh of ROOT cgroup doesn't depend on global number ?
> > 
> 
> I think in current implementation ROOT cgroup bdi_thres is always same
> as global number. It is only for other child groups where it is different
> from global number because of reduced dirytable_memory() limit. And we
> don't seem to be allowing any control on root group. 
> 
> But I am wondering, what happens in following case.
> 
> IIUC, with use_hierarhy=0, if I create two test groups test1 and test2, then
> hierarchy looks as follows.
> 
> 			root  test1  test2
> 
> Now root group's DIRTYABLE is still system wide but test1 and test2's
> dirtyable will be reduced based on RES_LIMIT in those groups.
> 
> Conceptually, per cgroup dirty ratio is like fixing page cache share of
> each group. So effectively we are saying that these limits apply to only
> child group of root but not to root as such?

Correct. In this implementation root cgroup means "outside all cgroups".
I think this can be an acceptable behaviour since in general we don't
set any limit to the root cgroup.

>  
> > > So for the same number of dirty pages system wide on this bdi, we will be
> > > triggering writeouts much more aggressively if somebody has created few
> > > memory cgroups and tasks are running in those cgroups.
> > > 
> > > I guess it might cause performance regressions in case of small file
> > > writeouts because previously one could have written the file to cache and
> > > be done with it but with this patch set, there are higher changes that
> > > you will be throttled to write the pages back to disk.
> > > 
> > > I guess we need two pieces to resolve this.
> > > 	- BDI stats per cgroup.
> > > 	- Writeback of inodes from same cgroup.
> > > 
> > > I think BDI stats per cgroup will increase the complextiy.
> > > 
> > Thank you for clarification. IIUC, dirty_limit implemanation shoul assume
> > there is I/O resource controller, maybe usual users will use I/O resource
> > controller and memcg at the same time.
> > Then, my question is what happens when used with I/O resource controller ?
> > 
> 
> Currently IO resource controller keep all the async IO queues in root
> group so we can't measure exactly. But my guess is until and unless we
> at least implement "writeback inodes from same cgroup" we will not see
> increased flow of writes from one cgroup over other cgroup.

Agreed. And I plan to look a the "writeback inodes per cgroup" feature
soon. I'm sorry but I've some deadlines this week, so probably I'll
start working on this in the next weekend.

-Andrea
