From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: [PATCH 04/11] cgroups: New cancel_attach_task subsystem callback
Date: Tue, 13 Sep 2011 01:11:24 +0200
Message-ID: <1315869091-18933-5-git-send-email-fweisbec@gmail.com>
References: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1315869091-18933-1-git-send-email-fweisbec@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Frederic Weisbecker <fweisbec@gmail.com>, Containers <containers@lists.osdl.org>, Li Zefan <lizf@cn.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Aditya Kali <adityakali@google.com>, Oleg Nesterov <oleg@redhat.com>, Kay Sievers <kay.sievers@vrfy.org>, Tim Hockin <thockin@hockin.org>, Tejun Heo <tj@kernel.org>
List-Id: containers.vger.kernel.org

To cancel a process attachment on a subsystem, we only call the
cancel_attach() callback once on the leader but we have no
way to cancel the attachment individually for each member of
the process group.

This is going to be needed for the max number of tasks susbystem
that is coming.

To prepare for this integration, call a new cancel_attach_task()
callback on each task of the group until we reach the member that
failed to attach.

Signed-off-by: Frederic Weisbecker <fweisbec@gmail.com>
Acked-by: Paul Menage <paul@paulmenage.org>
Cc: Li Zefan <lizf@cn.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Aditya Kali <adityakali@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kay Sievers <kay.sievers@vrfy.org>
Cc: Tim Hockin <thockin@hockin.org>
Cc: Tejun Heo <tj@kernel.org>
---
 Documentation/cgroups/cgroups.txt |    7 +++++++
 include/linux/cgroup.h            |    2 ++
 kernel/cgroup.c                   |   24 ++++++++++++++++++++----
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/Documentation/cgroups/cgroups.txt b/Documentation/cgroups/cgroups.txt
index 0621e93..3bc1dc9 100644
--- a/Documentation/cgroups/cgroups.txt
+++ b/Documentation/cgroups/cgroups.txt
@@ -623,6 +623,13 @@ function, so that the subsystem can implement a rollback. If not, not necessary.
 This will be called only about subsystems whose can_attach() operation have
 succeeded.
 
+void cancel_attach_task(struct cgroup *cgrp, struct task_struct *tsk)
+(cgroup_mutex held by caller)
+
+As cancel_attach, but for operations that must be cancelled once per
+task that wanted to be attached. This typically revert the effect of
+can_attach_task().
+
 void pre_attach(struct cgroup *cgrp);
 (cgroup_mutex held by caller)
 
diff --git a/include/linux/cgroup.h b/include/linux/cgroup.h
index ed34eb8..b62cf5e 100644
--- a/include/linux/cgroup.h
+++ b/include/linux/cgroup.h
@@ -472,6 +472,8 @@ struct cgroup_subsys {
 			       struct task_struct *tsk);
 	void (*cancel_attach)(struct cgroup_subsys *ss, struct cgroup *cgrp,
 			      struct task_struct *tsk);
+	void (*cancel_attach_task)(struct cgroup *cgrp,
+				   struct task_struct *tsk);
 	void (*pre_attach)(struct cgroup *cgrp);
 	void (*attach_task)(struct cgroup *cgrp, struct cgroup *old_cgrp,
 			    struct task_struct *tsk);
diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index fafebdb..709baef 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1883,6 +1883,9 @@ out:
 				 * remaining subsystems.
 				 */
 				break;
+
+			if (ss->cancel_attach_task)
+				ss->cancel_attach_task(cgrp, tsk);
 			if (ss->cancel_attach)
 				ss->cancel_attach(ss, cgrp, tsk);
 		}
@@ -1992,7 +1995,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 {
 	int retval, i, group_size;
 	struct cgroup_subsys *ss, *failed_ss = NULL;
-	bool cancel_failed_ss = false;
+	struct task_struct *failed_task = NULL;
 	/* guaranteed to be initialized later, but the compiler needs this */
 	struct cgroup *oldcgrp = NULL;
 	struct css_set *oldcg;
@@ -2081,7 +2084,7 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 							     oldcgrp, tsk);
 				if (retval) {
 					failed_ss = ss;
-					cancel_failed_ss = true;
+					failed_task = tsk;
 					goto out_cancel_attach;
 				}
 			}
@@ -2146,8 +2149,11 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 				if (ss->attach_task)
 					ss->attach_task(cgrp, oldcgrp, tsk);
 			}
+		} else if (retval == -ESRCH) {
+			if (ss->cancel_attach_task)
+				ss->cancel_attach_task(cgrp, tsk);
 		} else {
-			BUG_ON(retval != -ESRCH);
+			BUG_ON(1);
 		}
 	}
 	/* nothing is sensitive to fork() after this point. */
@@ -2179,8 +2185,18 @@ out_cancel_attach:
 	/* same deal as in cgroup_attach_task */
 	if (retval) {
 		for_each_subsys(root, ss) {
+			if (ss->cancel_attach_task && (ss != failed_ss ||
+						       failed_task)) {
+				for (i = 0; i < group_size; i++) {
+					tsk = flex_array_get_ptr(group, i);
+					if (tsk == failed_task)
+						break;
+					ss->cancel_attach_task(cgrp, tsk);
+				}
+			}
+
 			if (ss == failed_ss) {
-				if (cancel_failed_ss && ss->cancel_attach)
+				if (failed_task && ss->cancel_attach)
 					ss->cancel_attach(ss, cgrp, leader);
 				break;
 			}
-- 
1.7.5.4
