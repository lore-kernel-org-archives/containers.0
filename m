From: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Subject: [RFC PATCH 1/9] cgroup: introduce cgroupfs_root flag ROOT_NAMESPACE
Date: Mon, 17 Dec 2012 14:43:27 +0800
Message-ID: <1355726615-15224-2-git-send-email-gaofeng__33079.8629358926$1355726661$gmane$org@cn.fujitsu.com>
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

1. add a new flag bit ROOT_NAMESPACE for cgroupfs_root,
   this bit is used for identifying whether this hierarchy
   is mounted in container(pid namespace).

2. add a field pid_ns in cgroupfs_root,points to which
   pidns this hierarchy belongs to.

Signed-off-by: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
---
 kernel/cgroup.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index f34c41b..7d095b7 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -129,6 +129,9 @@ struct cgroupfs_root {
 	/* Tracks how many cgroups are currently defined in hierarchy.*/
 	int number_of_cgroups;
 
+	/* The pid namespace this hierarchy belongs to */
+	struct pid_namespace *pid_ns;
+
 	/* A list running through the active hierarchies */
 	struct list_head root_list;
 
@@ -153,7 +156,9 @@ struct cgroupfs_root {
  * subsystems that are otherwise unattached - it never has more than a
  * single cgroup, and all tasks are part of that cgroup.
  */
-static struct cgroupfs_root rootnode;
+static struct cgroupfs_root rootnode = {
+	.pid_ns = &init_pid_ns,
+};
 
 /*
  * cgroupfs file entry, pointed to from leaf dentry->d_fsdata.
@@ -286,6 +291,7 @@ inline int cgroup_is_removed(const struct cgroup *cgrp)
 enum {
 	ROOT_NOPREFIX,	/* mounted subsystems have no named prefix */
 	ROOT_XATTR,	/* supports extended attributes */
+	ROOT_NAMESPACE,	/* mounted in container */
 };
 
 static int cgroup_is_releasable(const struct cgroup *cgrp)
@@ -1100,6 +1106,8 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 		seq_puts(seq, ",noprefix");
 	if (test_bit(ROOT_XATTR, &root->flags))
 		seq_puts(seq, ",xattr");
+	if (test_bit(ROOT_NAMESPACE, &root->flags))
+		seq_puts(seq, ",namespace");
 	if (strlen(root->release_agent_path))
 		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->top_cgroup.flags))
@@ -1342,7 +1350,7 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	removed_mask = root->subsys_mask & ~opts.subsys_mask;
 
 	/* Don't allow flags or name to change at remount */
-	if (opts.flags != root->flags ||
+	if (opts.flags != (root->flags & ~(1UL << ROOT_NAMESPACE)) ||
 	    (opts.name && strcmp(opts.name, root->name))) {
 		ret = -EINVAL;
 		drop_parsed_module_refcounts(opts.subsys_mask);
@@ -1479,6 +1487,10 @@ static struct cgroupfs_root *cgroup_root_from_opts(struct cgroup_sb_opts *opts)
 	root->subsys_mask = opts->subsys_mask;
 	root->flags = opts->flags;
 	ida_init(&root->cgroup_ida);
+	root->pid_ns = get_pid_ns(task_active_pid_ns(current));
+	if (root->pid_ns != &init_pid_ns)
+		set_bit(ROOT_NAMESPACE, &root->flags);
+
 	if (opts->release_agent)
 		strcpy(root->release_agent_path, opts->release_agent);
 	if (opts->name)
@@ -1498,6 +1510,7 @@ static void cgroup_drop_root(struct cgroupfs_root *root)
 	ida_remove(&hierarchy_ida, root->hierarchy_id);
 	spin_unlock(&hierarchy_id_lock);
 	ida_destroy(&root->cgroup_ida);
+	put_pid_ns(root->pid_ns);
 	kfree(root);
 }
 
-- 
1.7.7.6
