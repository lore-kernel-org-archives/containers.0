From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Wed, 3 Mar 2010 15:15:49 +0900
Message-ID: <20100303151549.5d3d686a.kamezawa.hiroyu__35039.5464724444$1267597215$gmane$org@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
	<20100303122906.9c613ab2.kamezawa.hiroyu@jp.fujitsu.com>
	<20100303150137.f56d7084.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100303150137.f56d7084.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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
Cc: Andrea Righi <arighi-vWjgImWzx8FBDgjK7y7TUQ@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org, Greg-FOgKQjlUJ6BQetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Suleiman Souhlal <suleiman-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, 3 Mar 2010 15:01:37 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> On Wed, 3 Mar 2010 12:29:06 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org> wrote:
> > On Wed, 3 Mar 2010 11:12:38 +0900
> > Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > 
> > > > diff --git a/mm/filemap.c b/mm/filemap.c
> > > > index fe09e51..f85acae 100644
> > > > --- a/mm/filemap.c
> > > > +++ b/mm/filemap.c
> > > > @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
> > > >  	 * having removed the page entirely.
> > > >  	 */
> > > >  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> > > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
> > > >  		dec_zone_page_state(page, NR_FILE_DIRTY);
> > > >  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > > >  	}
> > > (snip)
> > > > @@ -1096,6 +1113,7 @@ int __set_page_dirty_no_writeback(struct page *page)
> > > >  void account_page_dirtied(struct page *page, struct address_space *mapping)
> > > >  {
> > > >  	if (mapping_cap_account_dirty(mapping)) {
> > > > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, 1);
> > > >  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> > > >  		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> > > >  		task_dirty_inc(current);
> > > As long as I can see, those two functions(at least) calls mem_cgroup_update_state(),
> > > which acquires page cgroup lock, under mapping->tree_lock.
> > > But as I fixed before in commit e767e056, page cgroup lock must not acquired under
> > > mapping->tree_lock.
> > > hmm, we should call those mem_cgroup_update_state() outside mapping->tree_lock,
> > > or add local_irq_save/restore() around lock/unlock_page_cgroup() to avoid dead-lock.
> > > 
> > Ah, good catch! But hmmmmmm...
> > This account_page_dirtted() seems to be called under IRQ-disabled.
> > About  __remove_from_page_cache(), I think page_cgroup should have its own DIRTY flag,
> > then, mem_cgroup_uncharge_page() can handle it automatically.
> > 
> > But. there are no guarantee that following never happens. 
> > 	lock_page_cgroup()
> > 	    <=== interrupt.
> > 	    -> mapping->tree_lock()
> > Even if mapping->tree_lock is held with IRQ-disabled.
> > Then, if we add local_irq_save(), we have to add it to all lock_page_cgroup().
> > 
> > Then, hm...some kind of new trick ? as..
> > (Follwoing patch is not tested!!)
> > 
> If we can verify that all callers of mem_cgroup_update_stat() have always either aquired
> or not aquired tree_lock, this direction will work fine.
> But if we can't, we have to add local_irq_save() to lock_page_cgroup() like below.
> 

Agreed.
Let's try how we can write a code in clean way. (we have time ;)
For now, to me, IRQ disabling while lock_page_cgroup() seems to be a little
over killing. What I really want is lockless code...but it seems impossible
under current implementation.

I wonder the fact "the page is never unchareged under us" can give us some chances
...Hmm.

Thanks,
-Kame
