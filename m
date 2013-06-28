From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/9] cgroup: fix cgroup_add_cftypes() error handling
Date: Fri, 28 Jun 2013 16:45:39 -0700
Message-ID: <1372463145-4245-4-git-send-email-tj__37650.3985877664$1372463187$gmane$org@kernel.org>
References: <1372463145-4245-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1372463145-4245-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
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
Cc: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

cgroup_add_cftypes() uses cgroup_cfts_commit() to actually create the
files; however, both functions ignore actual file creation errors and
just assume success.  This can lead to, for example, blkio hierarchy
with some of the cgroups with only subset of interface files populated
after cfq-iosched is loaded under heavy memory pressure, which is
nasty.

This patch updates cgroup_cfts_commit() and cgroup_add_cftypes() to
guarantee that all files are created on success and no file is created
on failure.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 kernel/cgroup.c | 26 ++++++++++++++++++--------
 1 file changed, 18 insertions(+), 8 deletions(-)

diff --git a/kernel/cgroup.c b/kernel/cgroup.c
index 3df8e92..4682d81 100644
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@ -2836,8 +2836,8 @@ static void cgroup_cfts_prepare(void)
 	mutex_lock(&cgroup_mutex);
 }
 
-static void cgroup_cfts_commit(struct cgroup_subsys *ss,
-			       struct cftype *cfts, bool is_add)
+static int cgroup_cfts_commit(struct cgroup_subsys *ss,
+			      struct cftype *cfts, bool is_add)
 	__releases(&cgroup_mutex)
 {
 	LIST_HEAD(pending);
@@ -2846,12 +2846,13 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 	struct dentry *prev = NULL;
 	struct inode *inode;
 	u64 update_before;
+	int ret = 0;
 
 	/* %NULL @cfts indicates abort and don't bother if @ss isn't attached */
 	if (!cfts || ss->root == &cgroup_dummy_root ||
 	    !atomic_inc_not_zero(&sb->s_active)) {
 		mutex_unlock(&cgroup_mutex);
-		return;
+		return 0;
 	}
 
 	/*
@@ -2867,10 +2868,13 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 	inode = root->dentry->d_inode;
 	mutex_lock(&inode->i_mutex);
 	mutex_lock(&cgroup_mutex);
-	cgroup_addrm_files(root, ss, cfts, is_add);
+	ret = cgroup_addrm_files(root, ss, cfts, is_add);
 	mutex_unlock(&cgroup_mutex);
 	mutex_unlock(&inode->i_mutex);
 
+	if (ret)
+		goto out_deact;
+
 	/* add/rm files for all cgroups created before */
 	rcu_read_lock();
 	cgroup_for_each_descendant_pre(cgrp, root) {
@@ -2887,15 +2891,19 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 		mutex_lock(&inode->i_mutex);
 		mutex_lock(&cgroup_mutex);
 		if (cgrp->serial_nr < update_before && !cgroup_is_dead(cgrp))
-			cgroup_addrm_files(cgrp, ss, cfts, is_add);
+			ret = cgroup_addrm_files(cgrp, ss, cfts, is_add);
 		mutex_unlock(&cgroup_mutex);
 		mutex_unlock(&inode->i_mutex);
 
 		rcu_read_lock();
+		if (ret)
+			break;
 	}
 	rcu_read_unlock();
 	dput(prev);
+out_deact:
 	deactivate_super(sb);
+	return ret;
 }
 
 /**
@@ -2915,6 +2923,7 @@ static void cgroup_cfts_commit(struct cgroup_subsys *ss,
 int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 {
 	struct cftype_set *set;
+	int ret;
 
 	set = kzalloc(sizeof(*set), GFP_KERNEL);
 	if (!set)
@@ -2923,9 +2932,10 @@ int cgroup_add_cftypes(struct cgroup_subsys *ss, struct cftype *cfts)
 	cgroup_cfts_prepare();
 	set->cfts = cfts;
 	list_add_tail(&set->node, &ss->cftsets);
-	cgroup_cfts_commit(ss, cfts, true);
-
-	return 0;
+	ret = cgroup_cfts_commit(ss, cfts, true);
+	if (ret)
+		cgroup_rm_cftypes(ss, cfts);
+	return ret;
 }
 EXPORT_SYMBOL_GPL(cgroup_add_cftypes);
 
-- 
1.8.3.1
