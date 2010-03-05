From: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/4] memcg: dirty pages accounting and limiting
	infrastructure
Date: Fri, 5 Mar 2010 12:31:33 +0530
Message-ID: <20100305070133.GJ3073@balbir.in.ibm.com>
References: <1267699215-4101-1-git-send-email-arighi@develer.com>
	<1267699215-4101-4-git-send-email-arighi@develer.com>
	<20100305101234.909001e8.nishimura@mxp.nes.nec.co.jp>
	<20100305105855.9b53176c.kamezawa.hiroyu@jp.fujitsu.com>
Reply-To: balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100305105855.9b53176c.kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Trond Myklebust <trond.myklebust-41N18TsMXrtuMpJDpNschA@public.gmane.org>, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Vivek Goyal <vgoyal-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

* KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> [2010-03-05 10:58:55]:

> On Fri, 5 Mar 2010 10:12:34 +0900
> Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> 
> > On Thu,  4 Mar 2010 11:40:14 +0100, Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org> wrote:
> > > Infrastructure to account dirty pages per cgroup and add dirty limit
> > >  static int mem_cgroup_count_children_cb(struct mem_cgroup *mem, void *data)
> > >  {
> > >  	int *val = data;
> > > @@ -1275,34 +1423,70 @@ static void record_last_oom(struct mem_cgroup *mem)
> > >  }
> > >  
> > >  /*
> > > - * Currently used to update mapped file statistics, but the routine can be
> > > - * generalized to update other statistics as well.
> > > + * Generalized routine to update file cache's status for memcg.
> > > + *
> > > + * Before calling this, mapping->tree_lock should be held and preemption is
> > > + * disabled.  Then, it's guarnteed that the page is not uncharged while we
> > > + * access page_cgroup. We can make use of that.
> > >   */
> > IIUC, mapping->tree_lock is held with irq disabled, so I think "mapping->tree_lock
> > should be held with irq disabled" would be enouth.
> > And, as far as I can see, callers of this function have not ensured this yet in [4/4].
> > 
> > how about:
> > 
> > 	void mem_cgroup_update_stat_locked(...)
> > 	{
> > 		...
> > 	}
> > 
> > 	void mem_cgroup_update_stat_unlocked(mapping, ...)
> > 	{
> > 		spin_lock_irqsave(mapping->tree_lock, ...);
> > 		mem_cgroup_update_stat_locked();
> > 		spin_unlock_irqrestore(...);
> > 	}
> >
> Rather than tree_lock, lock_page_cgroup() can be used if tree_lock is not held.
> 
> 		lock_page_cgroup();
> 		mem_cgroup_update_stat_locked();
> 		unlock_page_cgroup();
> 
> Andrea-san, FILE_MAPPED is updated without treelock, at least. You can't depend
> on migration_lock about FILE_MAPPED.
>

FILE_MAPPED is updated under pte lock in the rmap context and
page_cgroup lock within update_file_mapped.
 

-- 
	Three Cheers,
	Balbir
