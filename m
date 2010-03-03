From: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Subject: Re: [PATCH -mmotm 3/3] memcg: dirty pages instrumentation
Date: Wed, 3 Mar 2010 12:29:06 +0900
Message-ID: <20100303122906.9c613ab2.kamezawa.hiroyu__44635.3119019934$1267587226$gmane$org@jp.fujitsu.com>
References: <1267478620-5276-1-git-send-email-arighi@develer.com>
	<1267478620-5276-4-git-send-email-arighi@develer.com>
	<20100303111238.7133f8af.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100303111238.7133f8af.nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
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

On Wed, 3 Mar 2010 11:12:38 +0900
Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:

> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index fe09e51..f85acae 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -135,6 +135,7 @@ void __remove_from_page_cache(struct page *page)
> >  	 * having removed the page entirely.
> >  	 */
> >  	if (PageDirty(page) && mapping_cap_account_dirty(mapping)) {
> > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, -1);
> >  		dec_zone_page_state(page, NR_FILE_DIRTY);
> >  		dec_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> >  	}
> (snip)
> > @@ -1096,6 +1113,7 @@ int __set_page_dirty_no_writeback(struct page *page)
> >  void account_page_dirtied(struct page *page, struct address_space *mapping)
> >  {
> >  	if (mapping_cap_account_dirty(mapping)) {
> > +		mem_cgroup_update_stat(page, MEM_CGROUP_STAT_FILE_DIRTY, 1);
> >  		__inc_zone_page_state(page, NR_FILE_DIRTY);
> >  		__inc_bdi_stat(mapping->backing_dev_info, BDI_DIRTY);
> >  		task_dirty_inc(current);
> As long as I can see, those two functions(at least) calls mem_cgroup_update_state(),
> which acquires page cgroup lock, under mapping->tree_lock.
> But as I fixed before in commit e767e056, page cgroup lock must not acquired under
> mapping->tree_lock.
> hmm, we should call those mem_cgroup_update_state() outside mapping->tree_lock,
> or add local_irq_save/restore() around lock/unlock_page_cgroup() to avoid dead-lock.
> 
Ah, good catch! But hmmmmmm...
This account_page_dirtted() seems to be called under IRQ-disabled.
About  __remove_from_page_cache(), I think page_cgroup should have its own DIRTY flag,
then, mem_cgroup_uncharge_page() can handle it automatically.

But. there are no guarantee that following never happens. 
	lock_page_cgroup()
	    <=== interrupt.
	    -> mapping->tree_lock()
Even if mapping->tree_lock is held with IRQ-disabled.
Then, if we add local_irq_save(), we have to add it to all lock_page_cgroup().

Then, hm...some kind of new trick ? as..
(Follwoing patch is not tested!!)

==
---
 include/linux/page_cgroup.h |   14 ++++++++++++++
 mm/memcontrol.c             |   27 +++++++++++++++++----------
 2 files changed, 31 insertions(+), 10 deletions(-)

Index: mmotm-2.6.33-Feb11/include/linux/page_cgroup.h
===================================================================
--- mmotm-2.6.33-Feb11.orig/include/linux/page_cgroup.h
+++ mmotm-2.6.33-Feb11/include/linux/page_cgroup.h
@@ -39,6 +39,7 @@ enum {
 	PCG_CACHE, /* charged as cache */
 	PCG_USED, /* this object is in use. */
 	PCG_ACCT_LRU, /* page has been accounted for */
+	PCG_MIGRATE, /* page cgroup is under memcg account migration */
 };
 
 #define TESTPCGFLAG(uname, lname)			\
@@ -73,6 +74,8 @@ CLEARPCGFLAG(AcctLRU, ACCT_LRU)
 TESTPCGFLAG(AcctLRU, ACCT_LRU)
 TESTCLEARPCGFLAG(AcctLRU, ACCT_LRU)
 
+TESTPCGFLAG(Migrate, MIGRATE)
+
 static inline int page_cgroup_nid(struct page_cgroup *pc)
 {
 	return page_to_nid(pc->page);
@@ -93,6 +96,17 @@ static inline void unlock_page_cgroup(st
 	bit_spin_unlock(PCG_LOCK, &pc->flags);
 }
 
+static inline unsigned long page_cgroup_migration_lock(struct page_cgroup *pc)
+{
+	local_irq_save(flags);
+	bit_spin_lock(PCG_MIGRATE, &pc->flags);
+}
+static inline void
+page_cgroup_migration_lock(struct page_cgroup *pc, unsigned long flags)
+{
+	bit_spin_lock(PCG_MIGRATE, &pc->flags);
+	local_irq_restore(flags);
+}
 #else /* CONFIG_CGROUP_MEM_RES_CTLR */
 struct page_cgroup;
 
Index: mmotm-2.6.33-Feb11/mm/memcontrol.c
===================================================================
--- mmotm-2.6.33-Feb11.orig/mm/memcontrol.c
+++ mmotm-2.6.33-Feb11/mm/memcontrol.c
@@ -1321,7 +1321,7 @@ bool mem_cgroup_handle_oom(struct mem_cg
  * Currently used to update mapped file statistics, but the routine can be
  * generalized to update other statistics as well.
  */
-void mem_cgroup_update_file_mapped(struct page *page, int val)
+void mem_cgroup_update_file_mapped(struct page *page, int val, int locked)
 {
 	struct mem_cgroup *mem;
 	struct page_cgroup *pc;
@@ -1329,22 +1329,27 @@ void mem_cgroup_update_file_mapped(struc
 	pc = lookup_page_cgroup(page);
 	if (unlikely(!pc))
 		return;
-
-	lock_page_cgroup(pc);
+	/*
+	 * if locked==1, mapping->tree_lock is held. We don't have to take
+	 * care of charge/uncharge. just think about migration.
+	 */
+	if (!locked)
+		lock_page_cgroup(pc);
+	else
+		page_cgroup_migration_lock(pc);
 	mem = pc->mem_cgroup;
-	if (!mem)
+	if (!mem || !PageCgroupUsed(pc))
 		goto done;
-
-	if (!PageCgroupUsed(pc))
-		goto done;
-
 	/*
 	 * Preemption is already disabled. We can use __this_cpu_xxx
 	 */
 	__this_cpu_add(mem->stat->count[MEM_CGROUP_STAT_FILE_MAPPED], val);
 
 done:
-	unlock_page_cgroup(pc);
+	if (!locked)
+		lock_page_cgroup(pc);
+	else
+		page_cgroup_migration_unlock(pc);
 }
 
 /*
@@ -1785,7 +1790,8 @@ static void __mem_cgroup_move_account(st
 	VM_BUG_ON(!PageCgroupLocked(pc));
 	VM_BUG_ON(!PageCgroupUsed(pc));
 	VM_BUG_ON(pc->mem_cgroup != from);
-
+		
+	page_cgroup_migration_lock(pc);
 	page = pc->page;
 	if (page_mapped(page) && !PageAnon(page)) {
 		/* Update mapped_file data for mem_cgroup */
@@ -1802,6 +1808,7 @@ static void __mem_cgroup_move_account(st
 	/* caller should have done css_get */
 	pc->mem_cgroup = to;
 	mem_cgroup_charge_statistics(to, pc, true);
+	page_cgroup_migration_lock(pc);
 	/*
 	 * We charges against "to" which may not have any tasks. Then, "to"
 	 * can be under rmdir(). But in current implementation, caller of




Thanks,
-Kame
