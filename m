From: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH -mmotm 0/5] memcg: per cgroup dirty limit (v6)
Date: Fri, 12 Mar 2010 11:07:27 +0100
Message-ID: <20100312100727.GC4438__15084.2924988412$1268388562$gmane$org@linux>
References: <1268175636-4673-1-git-send-email-arighi@develer.com>
	<20100311093913.07c9ca8a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311101726.f58d24e9.kamezawa.hiroyu@jp.fujitsu.com>
	<1268298865.5279.997.camel@twins>
	<20100311182500.0f3ba994.kamezawa.hiroyu@jp.fujitsu.com>
	<20100311184244.6735076a.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312101411.b2639128.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100312101411.b2639128.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Fri, Mar 12, 2010 at 10:14:11AM +0900, Daisuke Nishimura wrote:
> On Thu, 11 Mar 2010 18:42:44 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Thu, 11 Mar 2010 18:25:00 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > > Then, it's not problem that check pc->mem_cgroup is root cgroup or not
> > > without spinlock.
> > > ==
> > > void mem_cgroup_update_stat(struct page *page, int idx, bool charge)
> > > {
> > > 	pc = lookup_page_cgroup(page);
> > > 	if (unlikely(!pc) || mem_cgroup_is_root(pc->mem_cgroup))
> > > 		return;	
> > > 	...
> > > }
> > > ==
> > > This can be handle in the same logic of "lock failure" path.
> > > And we just do ignore accounting.
> > > 
> > > There are will be no spinlocks....to do more than this,
> > > I think we have to use "struct page" rather than "struct page_cgroup".
> > > 
> > Hmm..like this ? The bad point of this patch is that this will corrupt FILE_MAPPED
> > status in root cgroup. This kind of change is not very good.
> > So, one way is to use this kind of function only for new parameters. Hmm.
> IMHO, if we disable accounting file stats in root cgroup, it would be better
> not to show them in memory.stat to avoid confusing users.

Or just show the same values that we show in /proc/meminfo.. (I mean,
not actually the same, but coherent with them).

> But, hmm, I think accounting them in root cgroup isn't so meaningless.
> Isn't making mem_cgroup_has_dirty_limit() return false in case of root cgroup enough?

Agreed. Returning false from mem_cgroup_has_dirty_limit() is enough to
always use global stats for the writeback, so this shouldn't introduce
any overhead for the root cgroup (at least for this part).

-Andrea
