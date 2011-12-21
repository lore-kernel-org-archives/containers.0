From: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2 v2] cgroup: Remove unnecessary task_lock before fetching
	css_set on migration
Date: Wed, 21 Dec 2011 03:02:37 +0100
Message-ID: <1324432958-20414-2-git-send-email-fweisbec@gmail.com>
References: <1324432958-20414-1-git-send-email-fweisbec@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324432958-20414-1-git-send-email-fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
List-Id: containers.vger.kernel.org

When we fetch the css_set of the tasks on cgroup migration, we don't need
anymore to synchronize against cgroup_exit() that could swap the old one
with init_css_set. Now that we are using threadgroup_lock() during
the migrations, we don't need to worry about it anymore.

Signed-off-by: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Reviewed-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Reviewed-by: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Cc: Cgroups <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
---
 kernel/cgroup.c |   20 ++++++++++----------
 1 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index bc3caff..24f6d6f 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1850,14 +1850,14 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	struct css_set *newcg;
 
 	/*
-	 * get old css_set. we need to take task_lock and refcount it, because
-	 * an exiting task can change its css_set to init_css_set and drop its
-	 * old one without taking cgroup_mutex.
+	 * get old css_set. We are synchronized through threadgroup_lock()
+	 * against PF_EXITING setting such that we can't race against
+	 * cgroup_exit() changing the css_set to init_css_set and dropping the
+	 * old one.
 	 */
-	task_lock(tsk);
+	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	oldcg = tsk->cgroups;
 	get_css_set(oldcg);
-	task_unlock(tsk);
 
 	/* locate or allocate a new css_set for this task. */
 	if (guarantee) {
@@ -1879,9 +1879,7 @@ static int cgroup_task_migrate(struct cgroup *cgrp, struct cgroup *oldcgrp,
 	}
 	put_css_set(oldcg);
 
-	/* @tsk can't exit as its threadgroup is locked */
 	task_lock(tsk);
-	WARN_ON_ONCE(tsk->flags & PF_EXITING);
 	rcu_assign_pointer(tsk->cgroups, newcg);
 	task_unlock(tsk);
 
@@ -2182,11 +2180,13 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 		/* nothing to do if this task is already in the cgroup */
 		if (tc->cgrp == cgrp)
 			continue;
-		/* get old css_set pointer */
-		task_lock(tc->task);
+		/*
+		 * get old css_set pointer. threadgroup is locked so this is
+		 * safe against concurrent cgroup_exit() changing this to
+		 * init_css_set.
+		 */
 		oldcg = tc->task->cgroups;
 		get_css_set(oldcg);
-		task_unlock(tc->task);
 		/* see if the new one for us is already in the list? */
 		if (css_set_check_fetched(cgrp, tc->task, oldcg, &newcg_list)) {
 			/* was already there, nothing to do. */
-- 
1.7.5.4
