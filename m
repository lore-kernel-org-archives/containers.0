From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: [RFC][BUGFIX] memcg: fix dead lock between cpuset and memcg (Re:
	[PATCH v5 3/3] cgroups: make procs file writable)
Date: Tue, 28 Dec 2010 11:43:52 +0900
Message-ID: <20101228114352.0992d32c.nishimura@mxp.nes.nec.co.jp>
References: <20100811054604.GA8743@ghc17.ghc.andrew.cmu.edu>
	<20100811054851.GD8743@ghc17.ghc.andrew.cmu.edu>
	<AANLkTimRM8rDe+u7fTy853RK=1mnLJMK57Tci2OLPR7L@mail.gmail.com>
	<AANLkTim7HW0wNyqOPePFXmEMV8hx_fMKNMTAsSwkRzZX@mail.gmail.com>
	<AANLkTin7aK5uEFi0U+iU_9=cbfRTHfDzKsbWupn73fSL@mail.gmail.com>
	<20101216002603.6741874a.akpm@linux-foundation.org>
	<20101224033352.GA7804@ghc17.ghc.andrew.cmu.edu>
	<20101225025508.GA649@ghc17.ghc.andrew.cmu.edu>
	<20101227095353.48d95687.nishimura@mxp.nes.nec.co.jp>
	<20101227042254.GA15417@ghc17.ghc.andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101227042254.GA15417-dJQ2lsn+DImqwBT9kiuFm8WGCVk0P7UB@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>, oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, Miao Xie <miaox-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, David Rientjes <rientjes-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <menage-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

> It looks to me like when memcg holds the mmap_sem the whole time, it's
> just to avoid the deadlock, not that there's there some need for the
> stuff under mmap_sem not to change between can_attach and attach. But if
> there is such a need, then the write-side in mpol_rebind_mm may conflict
> even with my proposed solution.
> 
> Regardless, the best way would be to avoid holding the mmap_sem across
> the whole window, possibly by solving the move_charge deadlock some
> other internal way, if at all possible?
> 
I made a patch to fix these probrems(deadlock between cpuset and memcg which
commit b1dd693e introduces, and deadlock which the commit fixed).
I'll test and resend this after new year holidays in Japan.

===
From: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>

The commit b1dd693e(memcg: avoid deadlock between move charge and try_charge())
can cause another deadlock about mmap_sem on task migration if cpuset and memcg
are mounted onto the same mount point.

After the commit, cgroup_attach_task() has sequence like:

cgroup_attach_task()
  ss->can_attach()
    cpuset_can_attach()
    mem_cgroup_can_attach()
      down_read(&mmap_sem)        (1)
  ss->attach()
    cpuset_attach()
      mpol_rebind_mm()
        down_write(&mmap_sem)     (2)
        up_write(&mmap_sem)
      cpuset_migrate_mm()
        do_migrate_pages()
          down_read(&mmap_sem)
          up_read(&mmap_sem)
    mem_cgroup_move_task()
      mem_cgroup_clear_mc()
        up_read(&mmap_sem)

We can cause deadlock at (2) because we've already aquire the mmap_sem at (1).

But the commit itself is necessary to fix deadlocks which have existed before
the commit like:

Ex.1)
                move charge             |        try charge
  --------------------------------------+------------------------------
    mem_cgroup_can_attach()             |  down_write(&mmap_sem)
      mc.moving_task = current          |    ..
      mem_cgroup_precharge_mc()         |  __mem_cgroup_try_charge()
        mem_cgroup_count_precharge()    |    prepare_to_wait()
          down_read(&mmap_sem)          |    if (mc.moving_task)
          -> cannot aquire the lock     |    -> true
                                        |      schedule()
                                        |      -> move charge should wake it up

Ex.2)
                move charge             |        try charge
  --------------------------------------+------------------------------
    mem_cgroup_can_attach()             |
      mc.moving_task = current          |
      mem_cgroup_precharge_mc()         |
        mem_cgroup_count_precharge()    |
          down_read(&mmap_sem)          |
          ..                            |
          up_read(&mmap_sem)            |
                                        |  down_write(&mmap_sem)
    mem_cgroup_move_task()              |    ..
      mem_cgroup_move_charge()          |  __mem_cgroup_try_charge()
        down_read(&mmap_sem)            |    prepare_to_wait()
        -> cannot aquire the lock       |    if (mc.moving_task)
                                        |    -> true
                                        |      schedule()
                                        |      -> move charge should wake it up

This patch fixes all of these problems by:
1. revert the commit.
2. To fix the Ex.1, we set mc.moving_task after mem_cgroup_count_precharge()
   has released the mmap_sem.
3. To fix the Ex.2, we use down_read_trylock() instead of down_read() in
   mem_cgroup_move_charge() and, if it has failed to aquire the lock, cancel
   all extra charges, wake up all waiters, and retry trylock.

Reported-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Signed-off-by: Daisuke Nishimura <nishimura-YQH0OdQVrdy45+QrQBaojngSJqDPrsil@public.gmane.org>
---
 mm/memcontrol.c |   78 +++++++++++++++++++++++++++++++------------------------
 1 files changed, 44 insertions(+), 34 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 7a22b41..b108b30 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -292,7 +292,6 @@ static struct move_charge_struct {
 	unsigned long moved_charge;
 	unsigned long moved_swap;
 	struct task_struct *moving_task;	/* a task moving charges */
-	struct mm_struct *mm;
 	wait_queue_head_t waitq;		/* a waitq for other context */
 } mc = {
 	.lock = __SPIN_LOCK_UNLOCKED(mc.lock),
@@ -4639,7 +4638,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 	unsigned long precharge;
 	struct vm_area_struct *vma;
 
-	/* We've already held the mmap_sem */
+	down_read(&mm->mmap_sem);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		struct mm_walk mem_cgroup_count_precharge_walk = {
 			.pmd_entry = mem_cgroup_count_precharge_pte_range,
@@ -4651,6 +4650,7 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 		walk_page_range(vma->vm_start, vma->vm_end,
 					&mem_cgroup_count_precharge_walk);
 	}
+	up_read(&mm->mmap_sem);
 
 	precharge = mc.precharge;
 	mc.precharge = 0;
@@ -4660,10 +4660,15 @@ static unsigned long mem_cgroup_count_precharge(struct mm_struct *mm)
 
 static int mem_cgroup_precharge_mc(struct mm_struct *mm)
 {
-	return mem_cgroup_do_precharge(mem_cgroup_count_precharge(mm));
+	unsigned long precharge = mem_cgroup_count_precharge(mm);
+
+	VM_BUG_ON(mc.moving_task);
+	mc.moving_task = current;
+	return mem_cgroup_do_precharge(precharge);
 }
 
-static void mem_cgroup_clear_mc(void)
+/* cancels all extra charges on mc.from and mc.to, and wakes up all waiters. */
+static void __mem_cgroup_clear_mc(void)
 {
 	struct mem_cgroup *from = mc.from;
 	struct mem_cgroup *to = mc.to;
@@ -4698,23 +4703,24 @@ static void mem_cgroup_clear_mc(void)
 						PAGE_SIZE * mc.moved_swap);
 		}
 		/* we've already done mem_cgroup_get(mc.to) */
-
 		mc.moved_swap = 0;
 	}
-	if (mc.mm) {
-		up_read(&mc.mm->mmap_sem);
-		mmput(mc.mm);
-	}
+	memcg_oom_recover(from);
+	memcg_oom_recover(to);
+	wake_up_all(&mc.waitq);
+}
+
+static void mem_cgroup_clear_mc(void)
+{
+	struct mem_cgroup *from = mc.from;
+
+	__mem_cgroup_clear_mc();
 	spin_lock(&mc.lock);
 	mc.from = NULL;
 	mc.to = NULL;
 	spin_unlock(&mc.lock);
 	mc.moving_task = NULL;
-	mc.mm = NULL;
 	mem_cgroup_end_move(from);
-	memcg_oom_recover(from);
-	memcg_oom_recover(to);
-	wake_up_all(&mc.waitq);
 }
 
 static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
@@ -4736,38 +4742,23 @@ static int mem_cgroup_can_attach(struct cgroup_subsys *ss,
 			return 0;
 		/* We move charges only when we move a owner of the mm */
 		if (mm->owner == p) {
-			/*
-			 * We do all the move charge works under one mmap_sem to
-			 * avoid deadlock with down_write(&mmap_sem)
-			 * -> try_charge() -> if (mc.moving_task) -> sleep.
-			 */
-			down_read(&mm->mmap_sem);
-
 			VM_BUG_ON(mc.from);
 			VM_BUG_ON(mc.to);
 			VM_BUG_ON(mc.precharge);
 			VM_BUG_ON(mc.moved_charge);
 			VM_BUG_ON(mc.moved_swap);
-			VM_BUG_ON(mc.moving_task);
-			VM_BUG_ON(mc.mm);
-
 			mem_cgroup_start_move(from);
 			spin_lock(&mc.lock);
 			mc.from = from;
 			mc.to = mem;
-			mc.precharge = 0;
-			mc.moved_charge = 0;
-			mc.moved_swap = 0;
 			spin_unlock(&mc.lock);
-			mc.moving_task = current;
-			mc.mm = mm;
+			/* We set mc.moving_task later */
 
 			ret = mem_cgroup_precharge_mc(mm);
 			if (ret)
 				mem_cgroup_clear_mc();
-			/* We call up_read() and mmput() in clear_mc(). */
-		} else
-			mmput(mm);
+		}
+		mmput(mm);
 	}
 	return ret;
 }
@@ -4855,7 +4846,19 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 	struct vm_area_struct *vma;
 
 	lru_add_drain_all();
-	/* We've already held the mmap_sem */
+retry:
+	if (unlikely(!down_read_trylock(&mm->mmap_sem))) {
+		/*
+		 * Someone who are holding the mmap_sem might be waiting in
+		 * waitq. So we cancel all extra charges, wake up all waiters,
+		 * and retry. Because we cancel precharges, we might not be able
+		 * to move enough charges, but moving charge is a best-effort
+		 * feature anyway, so it wouldn't be a big problem.
+		 */
+		__mem_cgroup_clear_mc();
+		cond_resched();
+		goto retry;
+	}
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		int ret;
 		struct mm_walk mem_cgroup_move_charge_walk = {
@@ -4874,6 +4877,7 @@ static void mem_cgroup_move_charge(struct mm_struct *mm)
 			 */
 			break;
 	}
+	up_read(&mm->mmap_sem);
 }
 
 static void mem_cgroup_move_task(struct cgroup_subsys *ss,
@@ -4882,11 +4886,17 @@ static void mem_cgroup_move_task(struct cgroup_subsys *ss,
 				struct task_struct *p,
 				bool threadgroup)
 {
-	if (!mc.mm)
+	struct mm_struct *mm;
+
+	if (!mc.to)
 		/* no need to move charge */
 		return;
 
-	mem_cgroup_move_charge(mc.mm);
+	mm = get_task_mm(p);
+	if (mm) {
+		mem_cgroup_move_charge(mm);
+		mmput(mm);
+	}
 	mem_cgroup_clear_mc();
 }
 #else	/* !CONFIG_MMU */
-- 
1.7.1
