From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 7/9] cgroup: attach container's tasks to proper cgroup
Date: Mon, 17 Dec 2012 14:43:33 +0800
Message-ID: <1355726615-15224-8-git-send-email-gaofeng__14805.3707358942$1355726674$gmane$org@cn.fujitsu.com>
References: <1355726615-15224-1-git-send-email-gaofeng@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1355726615-15224-1-git-send-email-gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Cc: tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org
List-Id: containers.vger.kernel.org

If cgroup is mounted in container,move container's
tasks to the top cgroup of container.

If cgroup is unmounted in container,move container's
tasks back to the host's cgroup.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   48 ++++++++++++++++++++++++++++++++++++++++++------
 1 files changed, 42 insertions(+), 6 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index ac61027..e077660 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -1110,6 +1110,7 @@ static int __rebind_subsystems_ns(struct cgroupfs_root *root,
 	struct cgroup *parent = NULL;
 	struct cgroupfs_root *top_root = NULL;
 	unsigned long bit;
+	struct tgid_iter iter;
 	int i;
 
 	removed_mask = root->actual_subsys_mask & ~final_subsys_mask;
@@ -1126,6 +1127,25 @@ static int __rebind_subsystems_ns(struct cgroupfs_root *root,
 		BUG_ON(parent == NULL);
 	}
 
+	/*
+	 * Attach container's tasks to host's cgroup,since this
+	 * top cgroup may be destroyed or changed. If task attaching
+	 * failed, return error immediately.
+	 */
+	if (cgrp->parent) {
+		int error;
+		iter.task = NULL;
+		iter.tgid = 1;
+		for (iter = next_tgid(root->pid_ns, iter); iter.task;
+		     iter.tgid += 1, iter = next_tgid(root->pid_ns, iter)) {
+			error = cgroup_attach_task(cgrp->parent, iter.task);
+			if (error && error != -ESRCH) {
+				put_task_struct(iter.task);
+				return error;
+			}
+		}
+	}
+
 	/* Process each subsystem */
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
 		struct cgroup_subsys *ss = subsys[i];
@@ -1158,15 +1178,31 @@ static int __rebind_subsystems_ns(struct cgroupfs_root *root,
 		}
 	}
 
-	root->top_root = top_root;
-	cgrp->parent = parent;
-
 	/* Link to new top_root or unlink when umounting */
-	if (top_root)
+	if (top_root) {
+		root->top_root = top_root;
+		cgrp->parent = parent;
+		/*
+		 * Attach container's tasks to the new top cgroup.
+		 * We don't care whether some tasks are not attached
+		 * to this cgroup successfully, it totally does no harm.
+		 */
+		iter.task = NULL;
+		iter.tgid = 1;
+		for (iter = next_tgid(root->pid_ns, iter); iter.task;
+		     iter.tgid += 1, iter = next_tgid(root->pid_ns, iter)) {
+			cgroup_attach_task(cgrp, iter.task);
+		}
+		atomic_inc(&top_root->sb->s_active);
+		top_root->number_of_cgroups++;
 		list_move_tail(&cgrp->allcg_node, &top_root->allcg_list);
-	else
+	} else {
+		root->top_root->number_of_cgroups--;
+		atomic_dec(&root->top_root->sb->s_active);
+		root->top_root = NULL;
+		cgrp->parent = NULL;
 		list_del_init(&cgrp->allcg_node);
-
+	}
 	return 0;
 out:
 	for (i = 0; i < CGROUP_SUBSYS_COUNT; i++) {
-- 
1.7.7.6
