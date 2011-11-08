From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH -mm] cgroup: Fix task counter common ancestor logic
Date: Tue,  8 Nov 2011 16:21:10 +0100
Message-ID: <1320765670-14181-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>, Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>, Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Id: containers.vger.kernel.org

The task counter subsystem has been written assuming that
can_attach_task/attach_task/cancel_attach_task calls are
serialized per task. This is true when we attach only one task
but not when we attach a whole thread group, in which case the
sequence is:

	for each thread
		if (can_attach_task() < 0)
			goto rollback

	for each_thread
		attach_task()

rollback:
	for each thread
		cancel_attach_task()

The common ancestor, searched on task_counter_attach_task(), can
thus change between each of these calls for a given task. This
breaks if some tasks in the thread group are not in the same cgroup
origin. The uncharge made in attach_task() or the rollback in
cancel_attach_task() there would have an erroneous propagation.

This can even break seriously is some scenario. For example there
with $PID beeing the pid of a multithread process:

	mkdir /dev/cgroup/cgroup0
	echo $PID > /dev/cgroup/cgroup0/cgroup.procs
	echo $PID > /dev/cgroup/tasks
	echo $PID > /dev/cgroup/cgroup0/cgroup.procs

On the last move, attach_task() is called on the thread leader with
the wrong common_ancestor, leading to a crash because we uncharge
a res_counter that doesn't exist:

	[  149.805063] BUG: unable to handle kernel NULL pointer dereference at 0000000000000040
	[  149.806013] IP: [<ffffffff810a0172>] __lock_acquire+0x62/0x15d0
	[  149.806013] PGD 51d38067 PUD 5119e067 PMD 0
	[  149.806013] Oops: 0000 [#1] PREEMPT SMP
	[  149.806013] Dumping ftrace buffer:
	[  149.806013]    (ftrace buffer empty)
	[  149.806013] CPU 3
	[  149.806013] Modules linked in:
	[  149.806013]
	[  149.806013] Pid: 1111, comm: spread_thread_g Not tainted 3.1.0-rc3+ #165 FUJITSU SIEMENS AMD690VM-FMH/AMD690VM-FMH
	[  149.806013] RIP: 0010:[<ffffffff810a0172>]  [<ffffffff810a0172>] __lock_acquire+0x62/0x15d0
	[  149.806013] RSP: 0018:ffff880051479b38  EFLAGS: 00010046
	[  149.806013] RAX: 0000000000000046 RBX: 0000000000000040 RCX: 0000000000000000
	[  149.868002] RDX: 0000000000000001 RSI: 0000000000000000 RDI: 0000000000000040
	[  149.868002] RBP: ffff880051479c08 R08: 0000000000000002 R09: 0000000000000001
	[  149.868002] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000002
	[  149.868002] R13: 0000000000000000 R14: 0000000000000000 R15: ffff880051f120a0
	[  149.868002] FS:  00007f1e01dd7700(0000) GS:ffff880057d80000(0000) knlGS:0000000000000000
	[  149.868002] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
	[  149.868002] CR2: 0000000000000040 CR3: 0000000051c59000 CR4: 00000000000006e0
	[  149.868002] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
	[  149.868002] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
	[  149.868002] Process spread_thread_g (pid: 1111, threadinfo ffff880051478000, task ffff880051f120a0)
	[  149.868002] Stack:
	[  149.868002]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
	[  149.868002]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
	[  149.868002]  0000000000000000 0000000000000000 0000000000000000 0000000000000000
	[  149.868002] Call Trace:
	[  149.868002]  [<ffffffff810a1d32>] lock_acquire+0xa2/0x1a0
	[  149.868002]  [<ffffffff810c373c>] ? res_counter_uncharge_until+0x4c/0xb0
	[  149.868002]  [<ffffffff8180802b>] _raw_spin_lock+0x3b/0x50
	[  149.868002]  [<ffffffff810c373c>] ? res_counter_uncharge_until+0x4c/0xb0
	[  149.868002]  [<ffffffff810c373c>] res_counter_uncharge_until+0x4c/0xb0
	[  149.868002]  [<ffffffff810c26c4>] task_counter_attach_task+0x44/0x50
	[  149.868002]  [<ffffffff810bffcd>] cgroup_attach_proc+0x5ad/0x720
	[  149.868002]  [<ffffffff810bfa99>] ? cgroup_attach_proc+0x79/0x720
	[  149.868002]  [<ffffffff810c01cf>] attach_task_by_pid+0x8f/0x220
	[  149.868002]  [<ffffffff810c0230>] ? attach_task_by_pid+0xf0/0x220
	[  149.868002]  [<ffffffff810c0230>] ? attach_task_by_pid+0xf0/0x220
	[  149.868002]  [<ffffffff810c0388>] cgroup_procs_write+0x28/0x40
	[  149.868002]  [<ffffffff810c0bd9>] cgroup_file_write+0x209/0x2f0
	[  149.868002]  [<ffffffff812b8d08>] ? apparmor_file_permission+0x18/0x20
	[  149.868002]  [<ffffffff8127ef43>] ? security_file_permission+0x23/0x90
	[  149.868002]  [<ffffffff81157038>] vfs_write+0xc8/0x190
	[  149.868002]  [<ffffffff811571f1>] sys_write+0x51/0x90
	[  149.868002]  [<ffffffff818102c2>] system_call_fastpath+0x16/0x1b

To solve this, keep the original cgroup of each thread in the thread
group cached in the flex array and pass it to can_attach_task()/attach_task()
and cancel_attach_task() so that the correct common ancestor between the old
and new cgroup can be safely retrieved for each task.

This is inspired by a previous patch from Li Zefan:
"[PATCH] cgroups: don't cache common ancestor in task counter subsys".

Reported-by: Ben Blum <bblum-OM76b2Iv3yLQjUSlxSEPGw@public.gmane.org>
Reported-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
Cc: Tim Hockin <thockin-Rl2oBbRerpQdnm+yROfE0A@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
---
 Documentation/cgroups/cgroups.txt |    3 +-
 include/linux/cgroup.h            |    2 +-
 kernel/cgroup.c                   |   48 ++++++++++++++++++++++--------------
 kernel/cgroup_task_counter.c      |   26 +++++++++++--------
 4 files changed, 47 insertions(+), 32 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 3bc1dc9..4ddb5ec 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -623,7 +623,8 @@ function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
 succeeded.
 
-void cancel_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+void cancel_attach_task(struct cgroup *cgrp, struct cgroup *old_cgrp,
+			struct task_struct *tsk)
 (cgroup_mutex held by caller)
 
 As cancel_attach, but for operations that must be cancelled once per
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index 9c8151e..ec90f6a 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -475,7 +475,7 @@ struct cgroup_subsys {
 			       struct task_struct *tsk);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			      struct task_struct *tsk);
-	void (*cancel_attach_task)(struct cgroup *cgrp,
+	void (*cancel_attach_task)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 				   struct task_struct *tsk);
 	void (*pre_attach)(struct cgroup *cgrp);
 	void (*attach_task)(struct cgroup *cgrp, struct cgroup *old_cgrp,
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 018df9d..181a059 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1885,7 +1885,7 @@ out:
 				break;
 
 			if (ss->cancel_attach_task)
-				ss->cancel_attach_task(cgrp, tsk);
+				ss->cancel_attach_task(cgrp, oldcgrp, tsk);
 			if (ss->cancel_attach)
 				ss->cancel_attach(ss, cgrp, tsk);
 		}
@@ -1983,6 +1983,11 @@ static int css_set_prefetch(struct cgroup *cgrp, struct css_set *cg,
 	return 0;
 }
 
+struct task_cgroup {
+	struct task_struct *tsk;
+	struct cgroup *oldcgrp;
+};
+
 /**
  * cgroup_attach_proc - attach all threads in a threadgroup to a cgroup
  * @cgrp: the cgroup to attach to
@@ -2003,6 +2008,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	/* threadgroup list cursor and array */
 	struct task_struct *tsk;
 	struct flex_array *group;
+	struct task_cgroup *tc;
 	/*
 	 * we need to make sure we have css_sets for all the tasks we're
 	 * going to move -before- we actually start moving them, so that in
@@ -2020,7 +2026,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	group_size = get_nr_threads(leader);
 	/* flex_array supports very large thread-groups better than kmalloc. */
-	group = flex_array_alloc(sizeof(struct task_struct *), group_size,
+	group = flex_array_alloc(sizeof(struct task_cgroup), group_size,
 				 GFP_KERNEL);
 	if (!group)
 		return -ENOMEM;
@@ -2047,14 +2053,18 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	tsk = leader;
 	i = 0;
 	do {
+		struct task_cgroup tsk_cgrp;
+
 		/* as per above, nr_threads may decrease, but not increase. */
 		BUG_ON(i >= group_size);
 		get_task_struct(tsk);
+		tsk_cgrp.tsk = tsk;
+		tsk_cgrp.oldcgrp = task_cgroup_from_root(tsk, root);
 		/*
 		 * saying GFP_ATOMIC has no effect here because we did prealloc
 		 * earlier, but it's good form to communicate our expectations.
 		 */
-		retval = flex_array_put_ptr(group, i, tsk, GFP_ATOMIC);
+		retval = flex_array_put(group, i, &tsk_cgrp, GFP_ATOMIC);
 		BUG_ON(retval != 0);
 		i++;
 	} while_each_thread(leader, tsk);
@@ -2077,14 +2087,13 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		if (ss->can_attach_task) {
 			/* run on each task in the threadgroup. */
 			for (i = 0; i < group_size; i++) {
-				tsk = flex_array_get_ptr(group, i);
-				oldcgrp = task_cgroup_from_root(tsk, root);
-
+				tc = flex_array_get(group, i);
 				retval = ss->can_attach_task(cgrp,
-							     oldcgrp, tsk);
+							     tc->oldcgrp,
+							     tc->tsk);
 				if (retval) {
 					failed_ss = ss;
-					failed_task = tsk;
+					failed_task = tc->tsk;
 					goto out_cancel_attach;
 				}
 			}
@@ -2097,10 +2106,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	INIT_LIST_HEAD(&newcg_list);
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
+		tc = flex_array_get(group, i);
+		tsk = tc->tsk;
 		/* nothing to do if this task is already in the cgroup */
-		oldcgrp = task_cgroup_from_root(tsk, root);
-		if (cgrp == oldcgrp)
+		if (cgrp == tc->oldcgrp)
 			continue;
 		/* get old css_set pointer */
 		task_lock(tsk);
@@ -2136,9 +2145,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 			ss->pre_attach(cgrp);
 	}
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
+		tc = flex_array_get(group, i);
+		tsk = tc->tsk;
+		oldcgrp = tc->oldcgrp;
 		/* leave current thread as it is if it's already there */
-		oldcgrp = task_cgroup_from_root(tsk, root);
 		if (cgrp == oldcgrp)
 			continue;
 		/* if the thread is PF_EXITING, it can just get skipped. */
@@ -2151,7 +2161,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 			}
 		} else if (retval == -ESRCH) {
 			if (ss->cancel_attach_task)
-				ss->cancel_attach_task(cgrp, tsk);
+				ss->cancel_attach_task(cgrp, oldcgrp, tsk);
 		} else {
 			BUG_ON(1);
 		}
@@ -2188,10 +2198,10 @@ out_cancel_attach:
 			if (ss->cancel_attach_task && (ss != failed_ss ||
 						       failed_task)) {
 				for (i = 0; i < group_size; i++) {
-					tsk = flex_array_get_ptr(group, i);
-					if (tsk == failed_task)
+					tc = flex_array_get(group, i);
+					if (tc->tsk == failed_task)
 						break;
-					ss->cancel_attach_task(cgrp, tsk);
+					ss->cancel_attach_task(cgrp, tc->oldcgrp, tc->tsk);
 				}
 			}
 
@@ -2206,8 +2216,8 @@ out_cancel_attach:
 	}
 	/* clean up the array of referenced threads in the group. */
 	for (i = 0; i < group_size; i++) {
-		tsk = flex_array_get_ptr(group, i);
-		put_task_struct(tsk);
+		tc = flex_array_get(group, i);
+		put_task_struct(tc->tsk);
 	}
 out_free_group_list:
 	flex_array_free(group);
diff --git a/kernel/cgroup_task_counter.c b/kernel/cgroup_task_counter.c
index 2374905..294044b 100644
--- a/kernel/cgroup_task_counter.c
+++ b/kernel/cgroup_task_counter.c
@@ -95,12 +95,6 @@ static void task_counter_exit(struct cgroup_subsys *ss, struct cgroup *cgrp,
 }
 
 /*
- * Protected amongst can_attach_task/attach_task/cancel_attach_task by
- * cgroup mutex
- */
-static struct res_counter *common_ancestor;
-
-/*
  * This does more than just probing the ability to attach to the dest cgroup.
  * We can not just _check_ if we can attach to the destination and do the real
  * attachment later in task_counter_attach_task() because a task in the dest
@@ -111,9 +105,10 @@ static int task_counter_can_attach_task(struct cgroup *cgrp,
 					struct cgroup *old_cgrp,
 					struct task_struct *tsk)
 {
+	int err;
+	struct res_counter *common_ancestor;
 	struct res_counter *res = cgroup_task_res_counter(cgrp);
 	struct res_counter *old_res = cgroup_task_res_counter(old_cgrp);
-	int err;
 
 	/*
 	 * When moving a task from a cgroup to another, we don't want
@@ -138,10 +133,15 @@ static int task_counter_can_attach_task(struct cgroup *cgrp,
 
 /* Uncharge the dest cgroup that we charged in task_counter_can_attach_task() */
 static void task_counter_cancel_attach_task(struct cgroup *cgrp,
+					    struct cgroup *old_cgrp,
 					    struct task_struct *tsk)
 {
-	res_counter_uncharge_until(cgroup_task_res_counter(cgrp),
-				   common_ancestor, 1);
+	struct res_counter *common_ancestor;
+	struct res_counter *res = cgroup_task_res_counter(cgrp);
+	struct res_counter *old_res = cgroup_task_res_counter(old_cgrp);
+
+	common_ancestor = res_counter_common_ancestor(res, old_res);
+	res_counter_uncharge_until(res, common_ancestor, 1);
 }
 
 /*
@@ -155,8 +155,12 @@ static void task_counter_attach_task(struct cgroup *cgrp,
 				     struct cgroup *old_cgrp,
 				     struct task_struct *tsk)
 {
-	res_counter_uncharge_until(cgroup_task_res_counter(old_cgrp),
-				   common_ancestor, 1);
+	struct res_counter *common_ancestor;
+	struct res_counter *res = cgroup_task_res_counter(cgrp);
+	struct res_counter *old_res = cgroup_task_res_counter(old_cgrp);
+
+	common_ancestor = res_counter_common_ancestor(res, old_res);
+	res_counter_uncharge_until(old_res, common_ancestor, 1);
 }
 
 static u64 task_counter_read_u64(struct cgroup *cgrp, struct cftype *cft)
-- 
1.7.5.4
