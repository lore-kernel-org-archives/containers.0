From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Thu, 11 Mar 2010 18:25:00 +0900
Message-ID: <20100311182500.0f3ba994.kamezawa.hiroyu__8338.06165396727$1268299767$gmane$org@jp.fujitsu.com>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1268298865.5279.997.camel@twins>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>
Cc: Trond-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Thu, 11 Mar 2010 10:14:25 +0100
Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org> wrote:

> On Thu, 2010-03-11 at 10:17 +0900, KAMEZAWA Hiroyuki wrote:
> > On Thu, 11 Mar 2010 09:39:13 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > > The performance overhead is not so huge in both solutions, but the impact on
> > > > performance is even more reduced using a complicated solution...
> > > > 
> > > > Maybe we can go ahead with the simplest implementation for now and start to
> > > > think to an alternative implementation of the page_cgroup locking and
> > > > charge/uncharge of pages.
> 
> FWIW bit spinlocks suck massive.
> 
> > > 
> > > maybe. But in this 2 years, one of our biggest concerns was the performance.
> > > So, we do something complex in memcg. But complex-locking is , yes, complex.
> > > Hmm..I don't want to bet we can fix locking scheme without something complex.
> > > 
> > But overall patch set seems good (to me.) And dirty_ratio and dirty_background_ratio
> > will give us much benefit (of performance) than we lose by small overheads.
> 
> Well, the !cgroup or root case should really have no performance impact.
> 
> > IIUC, this series affects trgger for background-write-out.
> 
> Not sure though, while this does the accounting the actual writeout is
> still !cgroup aware and can definately impact performance negatively by
> shrinking too much.
> 

Ah, okay, your point is !cgroup (ROOT cgroup case.)
I don't think accounting these file cache status against root cgroup is necessary.


BTW, in other thread, I'm now proposing this style. 
==
+void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
+{
+	struct page_cgroup *pc;
+
+	pc = lookup_page_cgroup(page);
+	if (unlikely(!pc))
+		return;
+
+	if (trylock_page_cgroup(pc)) {
+		__mem_cgroup_update_stat(pc, idx, charge);
+		unlock_page_cgroup(pc);
+	}
+	return;
==

Then, it's not problem that check pc->mem_cgroup is root cgroup or not
without spinlock.
==
void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
{
	pc = lookup_page_cgroup(page);
	if (unlikely(!pc) || mem_cgroup_is_root(pc->mem_cgroup))
		return;	
	...
}
==
This can be handle in the same logic of "lock failure" path.
And we just do ignore accounting.

There are will be no spinlocks....to do more than this,
I think we have to use "struct page" rather than "struct page_cgroup".

Thanks,
-Kame
