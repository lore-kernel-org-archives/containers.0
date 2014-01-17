From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 5/6] cgroup: update locking in cgroup_show_options()
Date: Fri, 17 Jan 2014 13:11:56 -0500
Message-ID: <1389982317-22225-6-git-send-email-tj@kernel.org>
References: <1389982317-22225-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1389982317-22225-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_show_options() grabs cgroup_root_mutex to protect the options
changing while printing; however, holding root_mutex or not doesn't
really make much difference for the function.  subsys_mask can be
atomically tested and most of the options aren't allowed to change
anyway once mounted.

The only field which needs synchronization is ->release_agent_path.
This patch introduces a dedicated spinlock to synchronize accesses to
the field and drops cgroup_root_mutex locking from
cgroup_show_options().  The next patch will remove cgroup_root_mutex.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3b2fda0..2736689 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -92,6 +92,12 @@ static DEFINE_MUTEX(cgroup_mutex);
 
 static DEFINE_MUTEX(cgroup_root_mutex);
 
+/*
+ * Protects cgroup_subsys->release_agent_path.  Modifying it also requires
+ * cgroup_mutex.  Reading requires either cgroup_mutex or this spinlock.
+ */
+static DEFINE_SPINLOCK(release_agent_path_lock);
+
 #define cgroup_assert_mutex_or_rcu_locked()				\
 	rcu_lockdep_assert(rcu_read_lock_held() ||			\
 			   lockdep_is_held(&cgroup_mutex),		\
@@ -1024,7 +1030,6 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 	struct cgroup_subsys *ss;
 	int ssid;
 
-	mutex_lock(&cgroup_root_mutex);
 	for_each_subsys(ss, ssid)
 		if (root->subsys_mask & (1 << ssid))
 			seq_printf(seq, ",%s", ss->name);
@@ -1034,13 +1039,16 @@ static int cgroup_show_options(struct seq_file *seq, struct dentry *dentry)
 		seq_puts(seq, ",noprefix");
 	if (root->flags & CGRP_ROOT_XATTR)
 		seq_puts(seq, ",xattr");
+
+	spin_lock(&release_agent_path_lock);
 	if (strlen(root->release_agent_path))
 		seq_printf(seq, ",release_agent=%s", root->release_agent_path);
+	spin_unlock(&release_agent_path_lock);
+
 	if (test_bit(CGRP_CPUSET_CLONE_CHILDREN, &root->top_cgroup.flags))
 		seq_puts(seq, ",clone_children");
 	if (strlen(root->name))
 		seq_printf(seq, ",name=%s", root->name);
-	mutex_unlock(&cgroup_root_mutex);
 	return 0;
 }
 
@@ -1262,8 +1270,11 @@ static int cgroup_remount(struct super_block *sb, int *flags, char *data)
 	if (ret)
 		goto out_unlock;
 
-	if (opts.release_agent)
+	if (opts.release_agent) {
+		spin_lock(&release_agent_path_lock);
 		strcpy(root->release_agent_path, opts.release_agent);
+		spin_unlock(&release_agent_path_lock);
+	}
  out_unlock:
 	kfree(opts.release_agent);
 	kfree(opts.name);
@@ -2172,7 +2183,9 @@ static int cgroup_release_agent_write(struct cgroup_subsys_state *css,
 	if (!cgroup_lock_live_group(css->cgroup))
 		return -ENODEV;
 	mutex_lock(&cgroup_root_mutex);
+	spin_lock(&release_agent_path_lock);
 	strcpy(css->cgroup->root->release_agent_path, buffer);
+	spin_unlock(&release_agent_path_lock);
 	mutex_unlock(&cgroup_root_mutex);
 	mutex_unlock(&cgroup_mutex);
 	return 0;
-- 
1.8.4.2
