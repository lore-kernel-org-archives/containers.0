From: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: [PATCH 5/5] cgroup: separate out cgroup_attach_proc error handling
	code
Date: Tue, 20 Dec 2011 15:14:33 -0800
Message-ID: <1324422873-31001-6-git-send-email-msb@chromium.org>
References: <1324422873-31001-1-git-send-email-msb@chromium.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1324422873-31001-1-git-send-email-msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Makes it easier to read the non-error path.

While at it, move the retval=0 assignment inside the !group_size
check. This way the comment describe this check is directly
above it(we also avoid an extra assignment not needed in the
normal path). Also return 0 directly instead of using retval.

Signed-off-by: Mandeep Singh Baines <msb-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: Li Zefan <lizf-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu-+CUm20s59erQFUHtdCDX3A@public.gmane.org>
Cc: Frederic Weisbecker <fweisbec-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Cc: Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: Paul Menage <paul-inf54ven1CmVyaH7bEyXVA@public.gmane.org>
---
 kernel/cgroup.c |   21 +++++++++++----------
 1 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 2ac9eee..9ce0872 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2067,9 +2067,10 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	read_unlock(&tasklist_lock);
 
 	/* methods shouldn't be called if no task is actually migrating */
-	retval = 0;
-	if (!group_size)
+	if (!group_size) {
+		retval = 0;
 		goto out_free_group_list;
+	}
 
 	/*
 	 * step 1: check that we can legitimately attach to the cgroup.
@@ -2126,20 +2127,20 @@ int cgroup_attach_proc(struct cgroup *cgrp, struct task_struct *leader)
 	 */
 	synchronize_rcu();
 	cgroup_wakeup_rmdir_waiter(cgrp);
-	retval = 0;
+	flex_array_free(group);
+	return 0;
+
 out_list_teardown:
 	for (i = 0; i < css_set_refs; i++) {
 		tc = flex_array_get(group, i);
 		put_css_set(tc->cg);
 	}
 out_cancel_attach:
-	if (retval) {
-		for_each_subsys(root, ss) {
-			if (ss == failed_ss)
-				break;
-			if (ss->cancel_attach)
-				ss->cancel_attach(ss, cgrp, &tset);
-		}
+	for_each_subsys(root, ss) {
+		if (ss == failed_ss)
+			break;
+		if (ss->cancel_attach)
+			ss->cancel_attach(ss, cgrp, &tset);
 	}
 out_free_group_list:
 	flex_array_free(group);
-- 
1.7.3.1
