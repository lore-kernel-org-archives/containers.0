From: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC] [PATCH -mm 2/2] use collected memory cgroup statistics for page
	writeback
Date: Fri, 12 Sep 2008 17:09:52 +0200
Message-ID: <1221232192-13553-3-git-send-email-righi.andrea__1482.18041654236$1221232450$gmane$org@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <>
References: <>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Balbir Singh <balbir-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: David Radford <dradford-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Marco Innocenti <m.innocenti-qooieK91W7JeoWH0uzbU5w@public.gmane.org>, =?utf-8?q?Fernando=20Luis=20V=C3=A1zquez=20Cao?= <fernando-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Carl Henrik Lunde <chlunde-om2ZC0WAoZIXWF+eFR7m5Q@public.gmane.org>, Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Divyesh Shah <dpshah-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, agk-9JcytcrH/bA+uJoB2kUjGw@public.gmane.org, Matt Heaton <matt-cT2on/YLNlBWk0Htik3J/w@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, eric.rannaud-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Use per-cgroup memory statistics to evaluate dirty limits, dirtyable memory and
start background writeout via pdflush.

Also add an argument to pdflush_operation() to pass the memory cgroup that
requested the background writeout. In this way pdflush is able to check the
cgroup dirty limits according to the cgroup statistics.

Signed-off-by: Andrea Righi <righi.andrea-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 fs/super.c                |    4 +-
 fs/sync.c                 |    7 ++-
 include/linux/writeback.h |   11 +++--
 kernel/trace/trace.c      |    2 +-
 mm/backing-dev.c          |    3 +-
 mm/page-writeback.c       |  115 +++++++++++++++++++++++++++-----------------
 mm/pdflush.c              |   10 +++-
 7 files changed, 95 insertions(+), 57 deletions(-)

diff --git a/fs/super.c b/fs/super.c
index f31ef82..33fbcaa 100644
--- a/fs/super.c
+++ b/fs/super.c
@@ -646,7 +646,7 @@ int do_remount_sb(struct super_block *sb, int flags, void *data, int force)
 	return 0;
 }
 
-static void do_emergency_remount(unsigned long foo)
+static void do_emergency_remount(struct mem_cgroup *unused, unsigned long foo)
 {
 	struct super_block *sb;
 
@@ -674,7 +674,7 @@ static void do_emergency_remount(unsigned long foo)
 
 void emergency_remount(void)
 {
-	pdflush_operation(do_emergency_remount, 0);
+	pdflush_operation(do_emergency_remount, NULL, 0);
 }
 
 /*
diff --git a/fs/sync.c b/fs/sync.c
index 2967562..aac77c3 100644
--- a/fs/sync.c
+++ b/fs/sync.c
@@ -42,9 +42,14 @@ asmlinkage long sys_sync(void)
 	return 0;
 }
 
+static void memcg_do_sync(struct mem_cgroup *unused, unsigned long wait)
+{
+	do_sync(wait);
+}
+
 void emergency_sync(void)
 {
-	pdflush_operation(do_sync, 0);
+	pdflush_operation(memcg_do_sync, NULL, 0);
 }
 
 /*
diff --git a/include/linux/writeback.h b/include/linux/writeback.h
index 12b15c5..dd5bc8a 100644
--- a/include/linux/writeback.h
+++ b/include/linux/writeback.h
@@ -5,6 +5,7 @@
 #define WRITEBACK_H
 
 #include <linux/sched.h>
+#include <linux/memcontrol.h>
 #include <linux/fs.h>
 
 struct backing_dev_info;
@@ -106,7 +107,7 @@ extern int vm_highmem_is_dirtyable;
 extern int block_dump;
 extern int laptop_mode;
 
-extern unsigned long determine_dirtyable_memory(void);
+extern unsigned long determine_dirtyable_memory(struct mem_cgroup *mem);
 
 extern int dirty_ratio_handler(struct ctl_table *table, int write,
 		struct file *filp, void __user *buffer, size_t *lenp,
@@ -117,8 +118,9 @@ struct file;
 int dirty_writeback_centisecs_handler(struct ctl_table *, int, struct file *,
 				      void __user *, size_t *, loff_t *);
 
-void get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
-		 struct backing_dev_info *bdi);
+void get_dirty_limits(struct mem_cgroup *mem, long *pbackground,
+		long *pdirty, long *pbdi_dirty,
+		struct backing_dev_info *bdi);
 
 void page_writeback_init(void);
 void balance_dirty_pages_ratelimited_nr(struct address_space *mapping,
@@ -133,7 +135,8 @@ balance_dirty_pages_ratelimited(struct address_space *mapping)
 typedef int (*writepage_t)(struct page *page, struct writeback_control *wbc,
 				void *data);
 
-int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0);
+int pdflush_operation(void (*fn)(struct mem_cgroup *, unsigned long),
+			struct mem_cgroup *mem, unsigned long arg0);
 int generic_writepages(struct address_space *mapping,
 		       struct writeback_control *wbc);
 int write_cache_pages(struct address_space *mapping,
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index bc6a22a..ec64004 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -2877,7 +2877,7 @@ tracing_entries_write(struct file *filp, const char __user *ubuf,
 			goto out;
 		}
 
-		freeable_pages = determine_dirtyable_memory();
+		freeable_pages = determine_dirtyable_memory(NULL);
 
 		/* we only allow to request 1/4 of useable memory */
 		if (pages_requested >
diff --git a/mm/backing-dev.c b/mm/backing-dev.c
index f2e574d..df6a01c 100644
--- a/mm/backing-dev.c
+++ b/mm/backing-dev.c
@@ -28,7 +28,8 @@ static int bdi_debug_stats_show(struct seq_file *m, void *v)
 	long dirty_thresh;
 	long bdi_thresh;
 
-	get_dirty_limits(&background_thresh, &dirty_thresh, &bdi_thresh, bdi);
+	get_dirty_limits(NULL, &background_thresh, &dirty_thresh,
+			&bdi_thresh, bdi);
 
 #define K(x) ((x) << (PAGE_SHIFT - 10))
 	seq_printf(m,
diff --git a/mm/page-writeback.c b/mm/page-writeback.c
index 17c6141..1a9b602 100644
--- a/mm/page-writeback.c
+++ b/mm/page-writeback.c
@@ -106,7 +106,8 @@ EXPORT_SYMBOL(laptop_mode);
 /* End of sysctl-exported parameters */
 
 
-static void background_writeout(unsigned long _min_pages);
+static void background_writeout(struct mem_cgroup *mem,
+				unsigned long _min_pages);
 
 /*
  * Scale the writeback cache size proportional to the relative writeout speeds.
@@ -136,7 +137,9 @@ static int calc_period_shift(void)
 {
 	unsigned long dirty_total;
 
-	dirty_total = (vm_dirty_ratio * determine_dirtyable_memory()) / 100;
+	dirty_total = (mem_cgroup_dirty_ratio(NULL)
+			* determine_dirtyable_memory(NULL))
+			/ 100;
 	return 2 + ilog2(dirty_total - 1);
 }
 
@@ -147,9 +150,9 @@ int dirty_ratio_handler(struct ctl_table *table, int write,
 		struct file *filp, void __user *buffer, size_t *lenp,
 		loff_t *ppos)
 {
-	int old_ratio = vm_dirty_ratio;
+	int old_ratio = mem_cgroup_dirty_ratio(NULL);
 	int ret = proc_dointvec_minmax(table, write, filp, buffer, lenp, ppos);
-	if (ret == 0 && write && vm_dirty_ratio != old_ratio) {
+	if (ret == 0 && write && mem_cgroup_dirty_ratio(NULL) != old_ratio) {
 		int shift = calc_period_shift();
 		prop_change_shift(&vm_completions, shift);
 		prop_change_shift(&vm_dirties, shift);
@@ -350,30 +353,35 @@ static unsigned long highmem_dirtyable_memory(unsigned long total)
  * Returns the numebr of pages that can currently be freed and used
  * by the kernel for direct mappings.
  */
-unsigned long determine_dirtyable_memory(void)
+unsigned long determine_dirtyable_memory(struct mem_cgroup *memcg)
 {
-	unsigned long x;
+	unsigned long mem_memory, memcg_memory;
 
-	x = global_page_state(NR_FREE_PAGES) + global_lru_pages();
+	memcg_memory = mem_cgroup_get_free_pages(memcg) +
+			mem_cgroup_global_lru_pages(memcg);
+	mem_memory = global_page_state(NR_FREE_PAGES) + global_lru_pages();
+	if (memcg_memory && (memcg_memory < mem_memory))
+		return memcg_memory;
 
 	if (!vm_highmem_is_dirtyable)
-		x -= highmem_dirtyable_memory(x);
+		mem_memory -= highmem_dirtyable_memory(mem_memory);
 
-	return x + 1;	/* Ensure that we never return 0 */
+	return mem_memory + 1;	/* Ensure that we never return 0 */
 }
 
 void
-get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
+get_dirty_limits(struct mem_cgroup *mem, long *pbackground,
+		long *pdirty, long *pbdi_dirty,
 		 struct backing_dev_info *bdi)
 {
 	int background_ratio;		/* Percentages */
 	int dirty_ratio;
 	long background;
 	long dirty;
-	unsigned long available_memory = determine_dirtyable_memory();
+	unsigned long available_memory = determine_dirtyable_memory(mem);
 	struct task_struct *tsk;
 
-	dirty_ratio = vm_dirty_ratio;
+	dirty_ratio = mem_cgroup_dirty_ratio(mem);
 	if (dirty_ratio < 5)
 		dirty_ratio = 5;
 
@@ -383,10 +391,12 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 
 	background = (background_ratio * available_memory) / 100;
 	dirty = (dirty_ratio * available_memory) / 100;
-	tsk = current;
-	if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
-		background += background / 4;
-		dirty += dirty / 4;
+	if (mem == NULL) {
+		tsk = current;
+		if (tsk->flags & PF_LESS_THROTTLE || rt_task(tsk)) {
+			background += background / 4;
+			dirty += dirty / 4;
+		}
 	}
 	*pbackground = background;
 	*pdirty = dirty;
@@ -409,16 +419,17 @@ get_dirty_limits(long *pbackground, long *pdirty, long *pbdi_dirty,
 
 		*pbdi_dirty = bdi_dirty;
 		clip_bdi_dirty_limit(bdi, dirty, pbdi_dirty);
-		task_dirty_limit(current, pbdi_dirty);
+		if (mem == NULL)
+			task_dirty_limit(current, pbdi_dirty);
 	}
 }
 
 /*
  * balance_dirty_pages() must be called by processes which are generating dirty
  * data.  It looks at the number of dirty pages in the machine and will force
- * the caller to perform writeback if the system is over `vm_dirty_ratio'.
- * If we're over `background_thresh' then pdflush is woken to perform some
- * writeout.
+ * the caller to perform writeback if the system is over
+ * `mem_cgroup_dirty_ratio()'.  If we're over `background_thresh' then pdflush
+ * is woken to perform some writeout.
  */
 static void balance_dirty_pages(struct address_space *mapping)
 {
@@ -441,12 +452,11 @@ static void balance_dirty_pages(struct address_space *mapping)
 			.range_cyclic	= 1,
 		};
 
-		get_dirty_limits(&background_thresh, &dirty_thresh,
+		get_dirty_limits(NULL, &background_thresh, &dirty_thresh,
 				&bdi_thresh, bdi);
 
-		nr_reclaimable = global_page_state(NR_FILE_DIRTY) +
-					global_page_state(NR_UNSTABLE_NFS);
-		nr_writeback = global_page_state(NR_WRITEBACK);
+		nr_reclaimable = mem_cgroup_nr_file_dirty(NULL);
+		nr_writeback = mem_cgroup_nr_writeback(NULL);
 
 		bdi_nr_reclaimable = bdi_stat(bdi, BDI_RECLAIMABLE);
 		bdi_nr_writeback = bdi_stat(bdi, BDI_WRITEBACK);
@@ -475,8 +485,9 @@ static void balance_dirty_pages(struct address_space *mapping)
 		if (bdi_nr_reclaimable) {
 			writeback_inodes(&wbc);
 			pages_written += write_chunk - wbc.nr_to_write;
-			get_dirty_limits(&background_thresh, &dirty_thresh,
-				       &bdi_thresh, bdi);
+			get_dirty_limits(NULL,
+					&background_thresh, &dirty_thresh,
+					&bdi_thresh, bdi);
 		}
 
 		/*
@@ -521,10 +532,13 @@ static void balance_dirty_pages(struct address_space *mapping)
 	 * background_thresh, to keep the amount of dirty memory low.
 	 */
 	if ((laptop_mode && pages_written) ||
-			(!laptop_mode && (global_page_state(NR_FILE_DIRTY)
-					  + global_page_state(NR_UNSTABLE_NFS)
-					  > background_thresh)))
-		pdflush_operation(background_writeout, 0);
+		(!laptop_mode &&
+			(mem_cgroup_nr_file_dirty(NULL) > background_thresh))) {
+		struct mem_cgroup *mem = get_current_mem_cgroup();
+
+		if (pdflush_operation(background_writeout, mem, 0))
+			put_mem_cgroup(mem);
+	}
 }
 
 void set_page_dirty_balance(struct page *page, int page_mkwrite)
@@ -585,8 +599,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
 	long dirty_thresh;
 
         for ( ; ; ) {
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
-
+		get_dirty_limits(NULL, &background_thresh, &dirty_thresh,
+				NULL, NULL);
                 /*
                  * Boost the allowable dirty threshold a bit for page
                  * allocators so they don't get DoS'ed by heavy writers
@@ -612,7 +626,8 @@ void throttle_vm_writeout(gfp_t gfp_mask)
  * writeback at least _min_pages, and keep writing until the amount of dirty
  * memory is less than the background threshold, or until we're all clean.
  */
-static void background_writeout(unsigned long _min_pages)
+static void background_writeout(struct mem_cgroup *mem,
+				unsigned long _min_pages)
 {
 	long min_pages = _min_pages;
 	struct writeback_control wbc = {
@@ -628,9 +643,9 @@ static void background_writeout(unsigned long _min_pages)
 		long background_thresh;
 		long dirty_thresh;
 
-		get_dirty_limits(&background_thresh, &dirty_thresh, NULL, NULL);
-		if (global_page_state(NR_FILE_DIRTY) +
-			global_page_state(NR_UNSTABLE_NFS) < background_thresh
+		get_dirty_limits(mem, &background_thresh, &dirty_thresh,
+				NULL, NULL);
+		if (mem_cgroup_nr_file_dirty(mem) < background_thresh
 				&& min_pages <= 0)
 			break;
 		wbc.more_io = 0;
@@ -647,6 +662,7 @@ static void background_writeout(unsigned long _min_pages)
 				break;
 		}
 	}
+	put_mem_cgroup(mem);
 }
 
 /*
@@ -656,10 +672,15 @@ static void background_writeout(unsigned long _min_pages)
  */
 int wakeup_pdflush(long nr_pages)
 {
+	struct mem_cgroup *mem = get_current_mem_cgroup();
+	int ret;
+
 	if (nr_pages == 0)
-		nr_pages = global_page_state(NR_FILE_DIRTY) +
-				global_page_state(NR_UNSTABLE_NFS);
-	return pdflush_operation(background_writeout, nr_pages);
+		nr_pages = mem_cgroup_nr_file_dirty(NULL);
+	ret = pdflush_operation(background_writeout, mem, nr_pages);
+	if (ret)
+		put_mem_cgroup(mem);
+	return ret;
 }
 
 static void wb_timer_fn(unsigned long unused);
@@ -683,7 +704,7 @@ static DEFINE_TIMER(laptop_mode_wb_timer, laptop_timer_fn, 0, 0);
  * older_than_this takes precedence over nr_to_write.  So we'll only write back
  * all dirty pages if they are all attached to "old" mappings.
  */
-static void wb_kupdate(unsigned long arg)
+static void wb_kupdate(struct mem_cgroup *mem, unsigned long arg)
 {
 	unsigned long oldest_jif;
 	unsigned long start_jif;
@@ -704,8 +725,7 @@ static void wb_kupdate(unsigned long arg)
 	oldest_jif = jiffies - dirty_expire_interval;
 	start_jif = jiffies;
 	next_jif = start_jif + dirty_writeback_interval;
-	nr_to_write = global_page_state(NR_FILE_DIRTY) +
-			global_page_state(NR_UNSTABLE_NFS) +
+	nr_to_write = mem_cgroup_nr_file_dirty(mem) +
 			(inodes_stat.nr_inodes - inodes_stat.nr_unused);
 	while (nr_to_write > 0) {
 		wbc.more_io = 0;
@@ -724,6 +744,7 @@ static void wb_kupdate(unsigned long arg)
 		next_jif = jiffies + HZ;
 	if (dirty_writeback_interval)
 		mod_timer(&wb_timer, next_jif);
+	put_mem_cgroup(mem);
 }
 
 /*
@@ -742,18 +763,22 @@ int dirty_writeback_centisecs_handler(ctl_table *table, int write,
 
 static void wb_timer_fn(unsigned long unused)
 {
-	if (pdflush_operation(wb_kupdate, 0) < 0)
+	struct mem_cgroup *mem = get_current_mem_cgroup();
+
+	if (pdflush_operation(wb_kupdate, mem, 0) < 0) {
+		put_mem_cgroup(mem);
 		mod_timer(&wb_timer, jiffies + HZ); /* delay 1 second */
+	}
 }
 
-static void laptop_flush(unsigned long unused)
+static void laptop_flush(struct mem_cgroup *mem, unsigned long unused)
 {
 	sys_sync();
 }
 
 static void laptop_timer_fn(unsigned long unused)
 {
-	pdflush_operation(laptop_flush, 0);
+	pdflush_operation(laptop_flush, NULL, 0);
 }
 
 /*
diff --git a/mm/pdflush.c b/mm/pdflush.c
index 0cbe0c6..27f05b6 100644
--- a/mm/pdflush.c
+++ b/mm/pdflush.c
@@ -83,7 +83,9 @@ static unsigned long last_empty_jifs;
  */
 struct pdflush_work {
 	struct task_struct *who;	/* The thread */
-	void (*fn)(unsigned long);	/* A callback function */
+	void (*fn)(struct mem_cgroup *,
+			unsigned long);	/* A callback function */
+	struct mem_cgroup *mem;		/* callback memory cgroup argument */
 	unsigned long arg0;		/* An argument to the callback */
 	struct list_head list;		/* On pdflush_list, when idle */
 	unsigned long when_i_went_to_sleep;
@@ -124,7 +126,7 @@ static int __pdflush(struct pdflush_work *my_work)
 		}
 		spin_unlock_irq(&pdflush_lock);
 
-		(*my_work->fn)(my_work->arg0);
+		(*my_work->fn)(my_work->mem, my_work->arg0);
 
 		/*
 		 * Thread creation: For how long have there been zero
@@ -198,7 +200,8 @@ static int pdflush(void *dummy)
  * Returns zero if it indeed managed to find a worker thread, and passed your
  * payload to it.
  */
-int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0)
+int pdflush_operation(void (*fn)(struct mem_cgroup *, unsigned long),
+		struct mem_cgroup *mem, unsigned long arg0)
 {
 	unsigned long flags;
 	int ret = 0;
@@ -216,6 +219,7 @@ int pdflush_operation(void (*fn)(unsigned long), unsigned long arg0)
 		if (list_empty(&pdflush_list))
 			last_empty_jifs = jiffies;
 		pdf->fn = fn;
+		pdf->mem = mem;
 		pdf->arg0 = arg0;
 		wake_up_process(pdf->who);
 	}
-- 
1.5.4.3
