From: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: [PATCH 3/3] netcls_cgroup: implement proper hierarchy support
Date: Fri, 16 Nov 2012 19:31:02 -0800
Message-ID: <1353123062-23193-4-git-send-email-tj__18632.6575269506$1353123103$gmane$org@kernel.org>
References: <1353123062-23193-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <1353123062-23193-1-git-send-email-tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org, ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org, nhorman-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, tgraf-G/eBtMaohhA@public.gmane.org
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
List-Id: containers.vger.kernel.org

netcls_cgroup implemented rather weird hierarchy behavior.  A new
cgroup would inherit configuration from its parent but once created it
operates independently from its parent - updates to a parent doesn't
affect its children.

Proper hierarchy behavior can easily be implemented using cgroup
descendant iterator and the is_local flag.  Writing a positive value
to "net_cls.classid" updates the cgroup's classid and propagates the
classid downwards.  Writing a negative value removes the local config
and makes it inherit the parent's classid, and the inherited classid
is propagated downwards.

This makes netcls_cgroup properly hierarchical and behave the same way
as netprio_cgroup.

Signed-off-by: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
---
 net/sched/cls_cgroup.c | 62 +++++++++++++++++++++++++++++++++++++++++---------
 1 file changed, 51 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_cgroup.c b/net/sched/cls_cgroup.c
index 6e3ef64..e9e24ac 100644
--- a/net/sched/cls_cgroup.c
+++ b/net/sched/cls_cgroup.c
@@ -70,6 +70,44 @@ static u64 read_classid(struct cgroup *cgrp, struct cftype *cft)
 	return cgrp_cls_state(cgrp)->classid;
 }
 
+/**
+ * propagate_classid - proapgate classid configuration downwards
+ * @root: cgroup to propagate classid down from
+ *
+ * Propagate @root's classid to descendants of @root.  Each descendant of
+ * @root re-inherits from its parent in pre-order tree walk.  This should
+ * be called after the classid of @root is changed to keep the descendants
+ * up-to-date.
+ *
+ * This may race with a new cgroup coming online and propagation may happen
+ * before finishing ->css_online() or while being taken offline.  As a
+ * cgroup_cls_state is ready after ->css_alloc() and propagation doesn't
+ * affect the parent, this is safe.
+ *
+ * Should be called with netcls_mutex held.
+ */
+static void propagate_classid(struct cgroup *root)
+{
+	struct cgroup *pos;
+
+	lockdep_assert_held(&netcls_mutex);
+	rcu_read_lock();
+
+	cgroup_for_each_descendant_pre(pos, root) {
+		struct cgroup_cls_state *cs = cgrp_cls_state(pos);
+
+		/*
+		 * Don't propagate if @pos has local configuration.  We can
+		 * skip @pos's subtree but don't have to.  Just propagate
+		 * through for simplicity.
+		 */
+		if (!cs->is_local)
+			cs->classid = cgrp_cls_state(pos->parent)->classid;
+	}
+
+	rcu_read_unlock();
+}
+
 static int write_classid(struct cgroup *cgrp, struct cftype *cft,
 			 const char *buf)
 {
@@ -80,8 +118,19 @@ static int write_classid(struct cgroup *cgrp, struct cftype *cft,
 		return -EINVAL;
 
 	mutex_lock(&netcls_mutex);
-	cs->classid = clamp_val(v, 0, UINT_MAX);
-	cs->is_local = v >= 0;
+
+	if (v >= 0) {
+		cs->classid = clamp_val(v, 0, UINT_MAX);
+		cs->is_local = true;
+	} else {
+		if (cgrp->parent)
+			cs->classid = cgrp_cls_state(cgrp->parent)->classid;
+		else
+			cs->classid = 0;
+		cs->is_local = false;
+	}
+	propagate_classid(cgrp);
+
 	mutex_unlock(&netcls_mutex);
 	return 0;
 }
@@ -112,15 +161,6 @@ struct cgroup_subsys net_cls_subsys = {
 	.subsys_id	= net_cls_subsys_id,
 	.base_cftypes	= ss_files,
 	.module		= THIS_MODULE,
-
-	/*
-	 * While net_cls cgroup has the rudimentary hierarchy support of
-	 * inheriting the parent's classid on cgroup creation, it doesn't
-	 * properly propagates config changes in ancestors to their
-	 * descendents.  A child should follow the parent's configuration
-	 * but be allowed to override it.  Fix it and remove the following.
-	 */
-	.broken_hierarchy = true,
 };
 
 struct cls_cgroup_head {
-- 
1.7.11.7
